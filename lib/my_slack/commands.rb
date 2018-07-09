module MySlack
  class Commands
    COMMANDS = {
      help: {
        match: %w{ help },
        command: 'help',
        description: 'Prints this message'
      },
      status: {
        match: %w{ status available },
        command: 'status',
        description: 'Print the list of available support ninjas'
      },
      register: {
        match: %w{ register },
        command: 'register',
        description: 'Register as a support ninja'
      },
      away: {
        match: %w{ away gone },
        command: 'away',
        description: 'Mark yourself as away'
      },
      update_email: {
        match: %w{ update_email email },
        command: 'update_email',
        description: 'Update your associated Zendesk email'
      },
      products: {
        match: %w{ products product },
        command: 'products [subcommand]',
        description: 'Use `products help` for a list of subcommands'
      },
      here: {
        match: %{ back here },
        command: 'here [product]',
        description: 'Mark youself as available, you can optionally provide a product that you are working on.'
      },
      tickets: {
        match: %{ tickets ticket },
        command: 'tickets [subcommand]',
        description: 'Use `tickets help` for a list of subcommands'
      }
    }

    PLUGINS = [
      proc { |text,data| MySlack::Commands::bot_commands(text, data) },
      proc { |text,data| MySlack::Commands::watch_words(text, data) }
    ]

    def self.watch_words(text, data)
      message = nil
      matched = text.match(/ZD[-]{0,1}([\d]+)/)
      if matched
        message = MySlack::Tickets::info(matched[1])
      end

      message
    end

    def self.command_for_me?(text, data)
      first_word = text.split(/\s+/).first

      data['type'] == 'app_mention' && first_word.match?(/@#{MySlack.user_id}/)
    end

    def self.bot_commands(text, data)
      return unless command_for_me?(text, data)

      keyword = _keyword(text)
      cmd = _find_command(keyword);

      Rails.logger.info "Running command: #{cmd}, #{data}"
      message = self.send(cmd, text, data)
    end

    def self.process(text, data)
      message = nil
      PLUGINS.each do |plugin|
        response = plugin.call(text, data)

        unless response.nil?
          message = response.as_json
          message[:channel] ||= data['channel']
          message[:as_user] = true
          break
        end

      end
      message
    end

    def self._find_command(name)
      name.downcase!
      return name if COMMANDS.keys.include?(name)

      # check to see if it has an alias
      COMMANDS.each do |method, cmd|
        if cmd[:match].include?(name)
          return method
        end
      end

      # return a message if we don't know
      'unknown'
    end

    def self.mention?(text)

    end

    def self._keyword(text)
      words = text.split(/\s+/)
      # remove bot mention
      if words.first =~ /@[\w]+/
        words.shift
      end
      words.shift
    end

    class << self
      private

      def tickets(text, data = {})
        MySlack::Tickets.handle(text)
      end

      def unknown(text, data = {})
        message = MySlack::Message::new()
        message.push_attachment({
          title: "I'm sorry <@#{data['user']}>, I'm afraid I can't do that",
          text: "Unknown command: #{data['text']}",
          color: MySlack::ERROR
        })
        message
      end

      def help(text, data = {})
        fields = COMMANDS.values.map do |cmd|
          { title: cmd[:command], value: cmd[:description] }
        end
        message = MySlack::Message.new(text: 'Here is what I know how to do', channel: data['user'])
        message.push_attachment({
          fields: fields
        })
        message
      end

      def register(text, data = {})
        MySlack::People.register(data['user'])
      end

      def products(text, data = {})
        MySlack::Products.handle(text)
      end

      def status(text, data = {})
        MySlack::People.list()
      end

      def away(text, data = {})
        MySlack::People.set_away(data['user'])
      end

      def update_email(text, data = {})
        MySlack::People.update_email(data['user'], text)
      end

      def here(text, data = {})
        MySlack::People.set_here(data['user'], text)
      end
    end
  end
end

module MySlack
  class People
    class << self
      def list
        available = Person.where(available: true)
        unavailable = Person.where(available: false)

        message = MySlack::Message.new()
        message.public!

        if available.any?
          message.push_attachment({
            title: "These people are available",
            text: available.collect { |person| person.status(true) }.join("\n"),
            color: MySlack::SUCCESS
          })
        else
          message.text = "No one is currently available :frowning:"
        end

        if unavailable.any?
          message.push_attachment({
            title: "These people are unavailable",
            text: unavailable.collect { |person| person.status(true) }.join("\n"),
            color: MySlack::ERROR
          })
        end
        message
      end

      def set_away(slack_id)
        person = Person.where(slack_id: slack_id).first
        return user_not_found if person.nil?

        message = MySlack::Message.new()

        if person.set_away
          message.text = "Bye! Come back soon!"
        else
          message.text = "Error trying to set you away"
          message.add_attachment(person.errors.full_messages, MySlack::ERROR)
        end

        message
      end

      def register(slack_id)
        message = MySlack::Message.new()

        slack_info = MySlack::client.users_info(user: slack_id)
        if slack_info.ok
          @person = Person.new({ slack_id: slack_id, slack_handle: slack_info.user.name })
          if @person.save
            message.text = "You have been registered"
          else
            message.text = "There was an error registering your account"
            message.add_attachment(@person.errors.full_messages.join("\n"), MySlack::ERROR)
          end
        else
          message.text = "There was an error getting your user information"
        end

        message
      end

      def set_here(slack_id, product_name = nil)
        person = Person.where(slack_id: slack_id).first

        return user_not_found if person.nil?

        unless product_name.blank?
          product = Product.where(name: product_name).first

          # didn't find it with an exact match so search for something like it
          # TODO: need to handle what we do if we don't find anything
          product ||= Product.where("name ilike ?", "%#{product_name}%").first
        end

        message = MySlack::Message.new(text: 'Welcome back!')

        if person.set_here(product)
          message.push_attachment({
            fields: [{
              title: 'Working on',
              short: true,
              value: person.working_on
            }],
            color: MySlack::SUCCESS
          })
        else
          message.text = "Error trying to set you away"
          message.add_attachment(person.errors.full_messages, MySlack::ERROR)
        end

        message
      end

      def user_not_found
        message = MySlack::Message.new()
        message.add_attachment("Sorry, you are not registered as a support ninja", MySlack::ERROR)
        message
      end
    end
  end
end

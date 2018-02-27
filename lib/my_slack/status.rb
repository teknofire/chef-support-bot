module MySlack
  class Status
    def self.list
      available = Person.where(available: true)
      unavailable = Person.where(available: false)

      message = Message.new()
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

    def self.set_away(slack_id)
      person = Person.where(slack_id: slack_id).first
      message = Message.new()

      if person.set_away
        message.text = "Bye! Come back soon!"
      else
        message.text = "Error trying to set you away"
        message.add_attachment(person.errors.full_messages, MySlack::ERROR)
      end

      message
    end

    def self.set_here(slack_id, product_name = nil)
      person = Person.where(slack_id: slack_id).first

      unless product_name.blank?
        product = Product.where(name: product_name).first

        # didn't find it with an exact match so search for something like it
        # TODO: need to handle what we do if we don't find anything
        product ||= Product.where("name ilike ?", "%#{product_name}%").first
      end

      message = Message.new(text: 'Welcome back!')

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
  end
end

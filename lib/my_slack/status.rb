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
      end

      message
    end
  end
end

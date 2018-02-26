module MySlack
  class Message
    # attr_accessor :text, :link_names, :icon_emoji, :response_type, :attachments, :confirm

    def initialize(options = {})
      @message = {
        link_names: true,
        icon_emoji: ":monkey_face:",
        response_type: "ephemeral",
        attachments: [],
        text: ""
      }.merge(options)
    end

    def text=(msg)
      @message[:text] = msg
    end

    def push_attachment(item)
      @message[:attachments] ||= []
      @message[:attachments] << item
    end

    def add_attachment(*args)
      push_attachment(Attachment.new(*args))
    end

    def add_confirmation(message)
      push_attachment({
        "text": "Choose a game to play",
        "fallback": "You are unable to choose a game",
        "callback_id": "wopr_game",
        "color": "#3AA3E3",
        "attachment_type": "default",
        "actions": [
                {
                    "name": "game",
                    "text": "Chess",
                    "type": "button",
                    "value": "chess"
                }
          ]
      })
    end

    def private!
      @message[:response_type] = "ephemeral"
    end

    def public!
      @message[:response_type] = "in_channel"
    end

    def as_json(options = {})
      @message.as_json(options).symbolize_keys
    end
  end
end

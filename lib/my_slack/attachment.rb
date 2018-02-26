module MySlack
  class Attachment
    attr_accessor :color, :text, :fallback, :actions, :callback_id

    def initialize(message, color = MySlack::SUCCESS)
      self.text = message
      self.fallback = message
      self.color = color
    end

    def as_json(options = {})
      {
        text: self.text,
        fallback: self.fallback,
        color: self.color
      }
    end
  end
end

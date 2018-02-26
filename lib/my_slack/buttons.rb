module MySlack
  class Buttons < Attachment
    attr_accessor :actions

    def initialize(text = "", color = "")
      super
    end

    def add(name, display, value)
      self.actions ||= []
      self.actions << {
        name: name,
        text: display,
        type: 'button',
        value: value,
        callback_id: 'dismiss'
      }
    end

    def as_json(options = {})
      json = super
      json[:actions] = self.actions

      json
    end
  end
end

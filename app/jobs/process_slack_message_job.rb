class ProcessSlackMessageJob < ApplicationJob
  queue_as :default

  def perform(event_params)
    # Do something later
    case event_params['type']
    when 'app_mention', 'message'
      process_app_mention(event_params)
    else
      logger.info "We don't handle #{event_params['type']} yet"
    end
  end

  def process_app_mention(mention)
    logger.info mention.inspect
    msg = Slack::Messages::Formatting.unescape(mention['text'])
    # keyword, text = message_keyword(msg)

    message = ::MySlack::Commands.process(msg, mention)

    ::MySlack::client.chat_postMessage(message) unless message.nil?
  end

  def bot_match(word)
    /@(\w+) #{word}/
  end

  def find_person(id)
  end
end

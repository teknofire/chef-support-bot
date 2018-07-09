class ProcessSlackMessageJob < ApplicationJob
  queue_as :default

  def perform(event_params)
    # Do something later
    case event_params['type']
    when 'app_mention', 'message'
      if !event_params['text'].nil? 
        process_app_mention(event_params)
      end
    else
      logger.info "We don't handle #{event_params['type']} yet"
    end
  end

  def process_app_mention(mention)
    logger.info mention.inspect
    msg = Slack::Messages::Formatting.unescape(mention['text'])

    message = ::MySlack::Commands.process(msg, mention)
    ::MySlack::client.chat_postMessage(message) unless message.nil?
  end
end

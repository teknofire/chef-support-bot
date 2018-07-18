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
    msg = Slack::Messages::Formatting.unescape(mention['text'])
    keyword, text = message_keyword(msg)

    message = ::MySlack::Commands.process(keyword, text, mention)
    logger.info "RESPOOOOOOONSE #{message.inspect}"
    ::MySlack::client.chat_postMessage(message)
  end

  def message_keyword(text)
    words = text.split(' ')
    if words.first =~ /@[\w]+/
      words.shift
    end
    [words.shift, words.join(' ')]
  end

  def bot_match(word)
    /@(\w+) #{word}/
  end

  def find_person(id)
  end
end

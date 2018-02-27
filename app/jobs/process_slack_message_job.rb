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
    msg = Slack::Messages::Formatting.unescape(mention['text'])
    keyword, text = message_keyword(msg)

    message = MySlack::Commands.process(keyword, text, mention)

    slack_client.chat_postMessage(message)
  end

  def slack_client
    unless @client
      @client = Slack::Web::Client.new
      @client.auth_test
    end

    @client
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

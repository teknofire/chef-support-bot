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
    keyword = message_keyword(msg)
    case keyword
    when 'status', 'available'
      message = MySlack::Status.list()
    when 'away'
      message = MySlack::Status.set_away(mention['user'])
    when 'help'
      message = MySlack::Message.new(channel: mention['user'])
      message.push_attachment({
        title: "Here is what I know how to do",
        text: MySlack::HELP,
        color: MySlack::SUCCESS
      })
    else
      message = MySlack::Message::new()
      message.push_attachment({
        title: "I'm sorry <@#{mention['user']}>, I'm afraid I can't do that",
        text: "Unknown keyword: #{keyword}",
        color: MySlack::ERROR
      })
      message.private!
      message = message
    end

    message = message.as_json
    message[:channel] ||= mention['channel']
    message[:as_user] = true

    slack_client.chat_postMessage(message)
  end

  def slack_client
    unless @client
      @client = Slack::Web::Client.new
      @client.auth_test
      @bot_info = @client.bots_info
      Rails.logger.info @bot_info.inspect
    end

    @client
  end

  def message_keyword(text)
    logger.info text.inspect
    words = text.split(' ')
    if words.first =~ /@[\w]+/
      words[1]
    else
      words.first
    end
  end

  def bot_match(word)
    /@(\w+) #{word}/
  end

  def find_person(id)
  end
end

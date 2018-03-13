class ZendeskClient < ZendeskAPI::Client
  def self.instance
    @instance ||= new do |config|
      config.url = Rails.application.secrets[:zendesk][:url]
      config.username = Rails.application.secrets[:zendesk][:username]
      config.token = Rails.application.secrets[:zendesk][:token]
      config.retry = true
      config.logger = Rails.logger
    end
  end
end

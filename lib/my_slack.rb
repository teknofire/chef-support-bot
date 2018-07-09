module MySlack
  SUCCESS = "#2ECC40".freeze
  ERROR = "#FF4136".freeze
  WARNING = "#FFA500".freeze

  def self.client
    unless @client
      @client = Slack::Web::Client.new
      auth = @client.auth_test
      @user_id = auth.user_id
    end

    @client
  end

  def self.user_id
    @user_id
  end

  def self.identity
    @identity ||= @client.users_info()
  end
end

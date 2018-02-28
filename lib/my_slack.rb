module MySlack
  SUCCESS = "#2ECC40".freeze
  ERROR = "#FF4136".freeze
  WARNING = "#FFA500".freeze


  def self.client
    unless @client
      @client = Slack::Web::Client.new
      @client.auth_test
    end

    @client
  end
end

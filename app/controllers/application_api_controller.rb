class ApplicationApiController < ActionController::Base
  before_action :validate_token

  private

  def validate_token
    # handle "payload" format
    if !params[:payload].nil?
      newparams = JSON.parse(params[:payload], :symbolize_names => true)
    else
      newparams = params
    end  
    if newparams[:token] != Rails.application.secrets.slack_token
      redirect_to api_invalid_token_url
    end
  end

  def find_person
    @person = Person.where(slack_id: params[:user_id]).first_or_create do |p|
      p.attributes = register_slack_params
    end
  end
end

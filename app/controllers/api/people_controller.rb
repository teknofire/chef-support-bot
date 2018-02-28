class Api::PeopleController < ApplicationApiController
  before_action :find_person, only: [:away, :here]

  # POST /people/register
  # Used for register new user from slack /support-register command
  def register
    logger.info params.inspect
    message = MySlack::People.register(params[:user_id])

    render json: message
  end

  def status
    render json: MySlack::People.list
  end

  def here
    unless params[:text].blank?

    end

    render json: MySlack::People.set_here(params[:user_id], params[:text])
  end

  def away
    render json: MySlack::People.set_away(params[:user_id])
  end

  private
    def register_slack_params
      {
        slack_id: params[:user_id],
        slack_handle: params[:user_name],
        available: true
      }
    end
end

class Api::PeopleController < ApplicationApiController
  before_action :find_person, only: [:away, :here]

  # POST /people/register
  # Used for register new user from slack /support-register command
  def register
    logger.info params.inspect
    @person = Person.new(register_slack_params)

    message = MySlack::Message.new()
    if @person.new_record?
      if @person.save
        message.text = "You have been registered"
      else
        message.text = "There was an error registering your account"
        message.add_attachment(@person.errors.full_messages.join("\n"), MySlack::ERROR)
      end
    else
      message.text = "You have already registered"
    end

    render json: message
  end

  def status
    render json: MySlack::Status.list
  end

  def here
    unless params[:text].blank?

    end

    render json: MySlack::Status.set_here(params[:user_id], params[:text])
  end

  def away
    render json: MySlack::Status.set_away(params[:user_id])
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

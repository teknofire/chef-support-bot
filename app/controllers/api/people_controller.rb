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
    message = MySlack::Message.new

    @product = Product.where("name ilike ?", "%#{params[:text]}%").first

    @person.update_attributes(available: true, product: @product)

    message.text = "Welcome back!"
    message.add_attachment("It looks like you're set to work on *#{@person.working_on}* tickets")

    render json: message
  end

  def away
    message = MySlack::Status.set_away(params[:user_id])
    render json: message
  end

  private
    # {"token"=>"a1B2c3D4e5F6", "team_id"=>"T8XEWREKD", "team_domain"=>"teknofire", "channel_id"=>"C8XEWRKMZ", "channel_name"=>"general", "user_id"=>"U8WU40EBA", "user_name"=>"will", "command"=>"/support-register", "text"=>""
    def register_slack_params
      {
        slack_id: params[:user_id],
        slack_handle: params[:user_name],
        available: true
      }
    end
end

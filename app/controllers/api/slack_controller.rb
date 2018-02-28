class Api::SlackController < ApplicationApiController
  skip_before_action :validate_token, only: [:invalid_token]

  def actions
    render json: nil
  end

  def invalid_token
    render json: nil, status: :unauthorized
  end

  # Note that these should respond with a 200 quickly. Any real work needs to be
  # processed by something else
  def events
    # ignore messages from bots!

    case params[:type]
    when 'url_verification'
      logger.info "verifying url"
      render json: { challenge: params[:challenge] }
    when 'event_callback'
      return unless event_params[:bot_id].nil?
      
      render json: nil
      ProcessSlackMessageJob.perform_later(event_params.as_json)
    else
      logger.info '*'*10
      logger.info "Unknown event type: #{event_type}"
      logger.info params.inspect
    end
  end

  private

  def event_params
    params.require(:event).permit(:type, :text, :channel, :authed_users, :user, :ts, :event_ts, :bot_id, attachments: [])
  end
end

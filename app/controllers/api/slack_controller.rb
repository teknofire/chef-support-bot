class Api::SlackController < ApplicationApiController
  skip_before_action :validate_token, only: [:invalid_token]

  def actions
    render json: nil
  end

  def invalid_token
    render json: nil, status: :unauthorized
  end

  def interactive
    payload = JSON.parse(params[:payload],:symbolize_names => true)
    case payload[:type]
    when 'interactive_message'
      ProcessInteractiveMessageJob.perform_later(payload.as_json)
    else
      logger.info '*'*10
      logger.info "Unknown interactive event type: #{payload[:type]}"
      logger.info params.inspect
    end  
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
      puts "PERFORMING LATERRZZZ"
    else
      logger.info '*'*10
      logger.info "Unknown event type: #{params[:type]}"
      logger.info params.inspect
    end
  end

  private

  def event_params
    params.require(:event).permit(:type, :text, :channel, :authed_users, :user, :ts, :event_ts, :bot_id, :client_msg_id, :channel_type, attachments: [])
  end

end

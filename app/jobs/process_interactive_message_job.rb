class ProcessInteractiveMessageJob < ApplicationJob
  queue_as :default

  def perform(event_params)
    # Do something later
    case event_params['type']
    when 'interactive_message'
      process_interactive_message(event_params)
    else
      logger.info "We don't handle #{event_params['type']} yet"
    end
  end

  def process_interactive_message(params)
    
    result = "pending"

    # if we recieve a "Take" response from anyone, let them try and take the ticket
    puts "----------------- #{params.inspect}"
    case params['actions'][0]['name']
    when 'take'
       result = ::MySlack::Tickets.confirm(params['actions'][0]['value'], params['user']['id'])
    when 'unavailable'
       person = Person.where('slack_handle like ?', params['user']['name']).first
       if person
            ticket = Ticket.where(zendesk_id: params['actions'][0]['value']).first
	    if ticket

	      logger.info "person: #{person.inspect}, ticket: #{ticket.inspect}"
	      result = person.set_away()
	      if person.set_away
                 result = "person #{params['user']['id']} set to away"
	      # if user is the assigned person for that ticket
	      if ticket['person_id'] == person['id'] 
	        result = ::MySlack::Tickets.deny(params['actions'][0]['value'], params['user']['id'])
	      end

   	      else 
                  result = "Error trying to set #{params['user']['id']} away"
              end
          end
       else
       end

    else
      logger.info "Some weird response to ticket confirmation prompt? #{params['actions'][0]['name']}"
    end
    
    message = params['previous_message'] || params['original_message']
    finaltext = message['text'] || "no text... error"
    finalattachments =  message['attachments']

    logger.info "========== [ finaltext: #{finaltext} ] ========="
    logger.info "========== [ finalattachments: #{finalattachments} ]========="
    logger.info "========== [ result: #{result} ]========="

    # if a ticket assignment has been successful, match the confirmation string and update the original message to reflect that    
    if result.include?("assigned")
      finaltext = "#{finaltext.gsub! 'awaiting confirmation...', result}"
      finalattachments = []				    
      logger.info "========== [ finaltext: #{finalattachments} ]========="
    elsif result.include?("can't")
    # if a ticket assignment is rejected, update status and re-roll
      finaltext = "#{finaltext.gsub! 'awaiting confirmation...', result}"
      logger.info "========== [ finaltext: #{finaltext} ]========="

      newmess = ::MySlack::Tickets.assign(params['actions'][0]['value']).as_json
      newmess[:channel] = params['channel']['id']
      newmess[:as_user] = true
      logger.info "REEEEROLLLLLLLLLLLL #{newmess}"
      
    elsif result.include?("away")
    	   
    else	  
      finaltext = "#{finaltext} ... #{result}"
    end



    
    logger.info "Confirmation response: #{finaltext} "	


    if !newmess.nil?
      ::MySlack::client.chat_postMessage(newmess)
      finalattachments = []
    end   
      ::MySlack::client.chat_update({:ts=>params['message_ts'], :channel=>params['channel']['id'], 
                                      :text => finaltext,
                                      :attachments => finalattachments})

       

  end

  def find_person(id)
  end

end

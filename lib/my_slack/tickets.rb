require 'action_view'
require 'action_view/helpers'

module MySlack
  class Tickets
    COMMANDS = %w{ list info assign help }
    class << self
      include ActionView::Helpers::DateHelper

      def handle(text)
        keyword, data = _parse_text(text)
        Rails.logger.info "Checking for keyword #{keyword}"
        if COMMANDS.include?(keyword)
          begin
            Rails.logger.info "Running ticket command #{keyword}, #{data.inspect}"
            send(keyword, data)
          rescue => e
            message = help('Error running the specified command, showing help')
            message.push_attachment({
              title: e.inspect,
              text: e.backtrace.join("\n")
            })
            message
          end
        else
          help('Unknown command, here is what you can do with tickets')
        end
      end

      def _parse_text(text)
        text.downcase!
        words = text.split(' ')  
        [words.shift, words.join(' ')]
      end

      def help(msg = "")
        msg = 'Here is what I can do with tickets' if msg.blank?

        message = MySlack::Message.new(text: msg)
        message.push_attachment({
          fields: [{
            title: 'list',
            value: 'Lists recent tickets',
          },{
            title: 'info [ticket_id]',
            value: 'Show info about the given ticket',
          },{
            title: 'assign [ticket_id] [product]',
            value: 'Assign ticket to a random support ninja',
          }, {
            title: 'help',
            value: 'Print this message'
          }]
        })

        message
      end

      def list(data)
        tickets = Ticket.order(created_at: :desc).limit(5)
        unless data.blank?
          person = Person.where('slack_handle like ?', "%#{data}%").first
          if person
            tickets = tickets.where(person: person)
          else
          end
        end

        banner = "Most recent ticket assignments"
        if person
          banner += " for #{person.slack_handle}"
        end
        message = MySlack::Message.new(text: banner)

        tickets.each do |ticket|
          message.push_attachment({
            text: ticket.zendesk_agent_url,
            fields: [{
              title: 'Agent',
              short: true,
              value: ticket.person.slack_handle
            }, {
              title: 'Assigned',
              short: true,
              value: time_ago_in_words(ticket.created_at) + " ago"
            }],
            color: MySlack::SUCCESS
          })
        end

        message
      end

      def info(data)
        ticket = Ticket.where(zendesk_id: data).first_or_initialize

        message = MySlack::Message.new(text: ticket.zendesk_agent_url, unfurl_links: false)
        message.push_attachment(ticket.zendesk_summary)

        message
      end

      def assign(data)
        ticket_id, product_name = data.split(' ')

        if ticket_id.blank?
          return MySlack::Message.new(text: "Please specify a ticket id")
        end

        if product_name.blank?
          product = nil
        else
          product = Product.where('name like ?', "%#{product_name}%").first
        end

        person = Person.where(product: product, available: true).sample
        # if we didn't find a person for a specified product try to find one for
        # any product
        person ||= Person.where(product: nil, available: true).sample

        if person.nil?
          MySlack::Message.new(text: "Unable to find someone to take that ticket :(")
        else
          create_assigned_ticket(ticket_id, person)
        end
      end

      def confirm(ticket_id,user_id)
        # pull in person with user_id to access zendesk email
	person = Person.where(slack_id: user_id).first

        # update zendesk ticket with new assignee
	ticket = Ticket.where(zendesk_id: ticket_id).first
	puts "Ticket is:  #{ticket.inspect}"

	updated = zendesk_assign(ticket,person)

        # update pending candidate field
        # create message with results and update slack

	if updated
	   response = "and has confirmed! #{person.user_mention} is now assigned to #{ticket_id}"
	else
	   response = "and tried to confirm, but something is fucked. :("
	end

        response
      end

      def deny(ticket_id,user_id)

        # update assignment to reflect denial
	ticket = Ticket.where(zendesk_id: ticket_id).first
        ticket.person = nil

	if ticket.save
	   response = "but can't accept!  Commencing automatic reassignment...?"
	else
	   response = "and tried to reject it, but something is fucked. :("
	end

        response
      end


      def zendesk_assign(ticket,person)
      	 current_try = "beginning zendesk_assign"
         begin
           current_try = "look up ticket #{ticket.zendesk_id}"
           @zendeskticket ||= ZendeskClient.instance.tickets.find!(id: ticket.zendesk_id,  :include => :users)

	   if @zendeskticket.assignee.nil?
              puts "nil assignment"
      	   else
              current_assignee = @zendeskticket.assignee.name
      	   end

           current_try = "look up zendesk user with person's email #{person.slack_email}"
      	   @zendeskuser = ZendeskClient.instance.users.search(:query => "#{person.slack_email}").first

           current_try = "assign ticket to found zendesk user #{ticket.zendesk_id}"
      	   @zendeskticket.assignee = @zendeskuser
      	   @zendeskticket.save!

	   return true

        rescue ZendeskAPI::Error::NetworkError, ZendeskAPI::Error::RecordNotFound => e
          puts "Something bad happened when trying to #{current_try}..."
          puts e.inspect
	  return false
        end

      end


      def create_assigned_ticket(ticket_id, person)
        ticket = Ticket.where(zendesk_id: ticket_id).first_or_initialize
        ticket.person = person
        message = MySlack::Message.new()

        if ticket.save
          message.text = "#{person.user_mention} has been selected to take #{ticket.zendesk_agent_url}, awaiting confirmation..."
	  message.push_attachment({
            "fallback": "Can you take this ticket?",
            "title": "Can you take this ticket?",
            "callback_id": "assignment_approval",
            "color": "#3AA3E3",
            "attachment_type": "interactive_message",
            "actions": [
                {
                    "name": "take",
                    "text": "Take ticket #{ticket_id}",
                    "type": "button",
                    "value": "#{ticket_id}"
                },
                {
                    "name": "unavailable",
                    "text": "I'm not available",
                    "type": "button",
                    "value": "#{ticket_id}"
                }
            ]
        })
        else
          message.push_attachment({ title: "Error saving ticket", text: ticket.errors.full_messages.join("\n"), color: MySlack::ERROR })
        end

        message
      end
    end
  end
end

require 'action_view'
require 'action_view/helpers'

module MySlack
  class Tickets
    COMMANDS = %w{ list info assign help }
    class << self
      include ActionView::Helpers::DateHelper

      def handle(text)
        keyword, data = _parse_text(text)
        if COMMANDS.include?(keyword)
          begin
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
          help('Unknown command, here is what you can do with products')
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

      def create_assigned_ticket(ticket_id, person)
        ticket = Ticket.where(zendesk_id: ticket_id).first_or_initialize
        ticket.person = person
        message = MySlack::Message.new()

        if ticket.save
          message.text = "Congrats #{person.user_mention}, you have been selected to take #{ticket.zendesk_agent_url}"
        else
          message.push_attachment({ title: "Error saving ticket", text: ticket.errors.full_messages.join("\n"), color: MySlack::ERROR })
        end

        message
      end
    end
  end
end

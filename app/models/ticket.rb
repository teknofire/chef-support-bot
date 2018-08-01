class Ticket < ApplicationRecord
  belongs_to :person, optional: true
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper

  validates :zendesk_id, uniqueness: { message: "ticket id has already been created"}
  # TODO:  validate that ticket exists in zendesk

  def zendesk_agent_url
    "https://getchef.zendesk.com/agent/tickets/#{zendesk_id}"
  end

  def zd_info
    @zd_info ||= ZendeskClient.instance.tickets.find!(id: zendesk_id,  :include => :users)
  end

  def zendesk_summary
    puts "ZENDESK INFO: #{zd_info.inspect}"
    {
      title: zd_info.subject,
      title_link: zendesk_agent_url,
      fields: [{
        title: 'Assigned Agent',
        short: true,
        value: "#{zd_info.assignee.try(:send, :name) || 'None'}"
      },{
        title: 'Pending Candidate',
        short: true,
        value: person.nil? ? 'None' : "<@#{person.slack_id}>"
      }, {
        title: 'Ticket Status',
        short: true,
        value: zd_info.status
      }, {
        title: 'Submitted',
        short: true,
        value: time_ago_in_words(zd_info.created_at) + " ago"
      }, {
        title: 'Last updated',
        short: true,
        value: time_ago_in_words(zd_info.updated_at) + " ago"
      }, {
        title: 'Description',
        value: truncate(zd_info.description, length: 500, separator: ' ')
      }]
    }
  end
end

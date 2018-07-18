class Ticket < ApplicationRecord
  belongs_to :person, optional: true
  include ActionView::Helpers::DateHelper

  validates :zendesk_id, uniqueness: { message: "ticket id has already been created"}
  # TODO:  validate that ticket exists in zendesk

  def zendesk_agent_url
    "https://getchef.zendesk.com/agent/tickets/#{zendesk_id}"
  end
  
  def zendesk_summary
    @zendeskinfo ||= ZendeskClient.instance.tickets.find!(id: zendesk_id,  :include => :users)

    {
      title: @zendeskinfo.subject,
      title_link: zendesk_agent_url,
      fields: [{
        title: 'Assigned Agent',
        short: true,
        value: "#{@zendeskinfo.assignee.name}"
      },{
        title: 'Pending Candidate',
        short: true,
        value: person.nil? ? 'None' : "<@#{person.slack_id}>"
      }, {
        title: 'Ticket Status',
        short: true,
        value: @zendeskinfo.status
      }, {
        title: 'Submitted',
        short: true,
        value: time_ago_in_words(@zendeskinfo.created_at) + " ago"
      }, {
        title: 'Last updated',
        short: true,
        value: time_ago_in_words(@zendeskinfo.updated_at) + " ago"
      }, {
        title: 'Description',
        value: @zendeskinfo.description
      }]
    }
  end
end

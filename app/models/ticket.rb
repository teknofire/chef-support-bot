class Ticket < ApplicationRecord
  belongs_to :person, optional: true
  include ActionView::Helpers::DateHelper

  validates :zendesk_id, uniqueness: { message: "ticket id has already been created"}

  def zendesk_agent_url
    "https://getchef.zendesk.com/agent/tickets/#{zendesk_id}"
  end

  def zendesk_summary
    @zendeskinfo ||= ZendeskClient.instance.ticket.find!(id: zendesk_id)

    {
      title: @zendeskinfo.subject,
      title_link: zendesk_agent_url,
      fields: [{
        title: 'Agent',
        short: true,
        value: person.nil? ? 'Unassigned' : person.slack_handle
      }, {
        title: 'Status',
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

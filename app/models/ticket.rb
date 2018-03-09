class Ticket < ApplicationRecord
  belongs_to :person, optional: true

  validates :zendesk_id, uniqueness: { message: "ticket id has already been created"}

  def zendesk_agent_url
    "https://getchef.zendesk.com/agent/tickets/#{zendesk_id}"
  end
end

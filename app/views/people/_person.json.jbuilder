json.extract! person, :id, :name, :slack_id, :slack_handle, :available, :product_id, :created_at, :updated_at
json.url person_url(person, format: :json)

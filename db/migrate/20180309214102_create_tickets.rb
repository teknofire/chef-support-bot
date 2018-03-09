class CreateTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :tickets do |t|
      t.string :zendesk_id
      t.references :person, foreign_key: true

      t.timestamps
    end
  end
end

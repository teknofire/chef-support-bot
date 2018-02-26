class CreatePeople < ActiveRecord::Migration[5.1]
  def change
    create_table :people do |t|
      t.string :name
      t.string :slack_id
      t.string :slack_handle
      t.boolean :available
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end

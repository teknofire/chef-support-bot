class AddSlackEmailToPeople < ActiveRecord::Migration[5.1]
  def change
    add_column :people, :slack_email, :string
  end
end

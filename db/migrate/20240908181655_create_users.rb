class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :last_name
      t.string :login
      t.string :email
      t.string :phone_number
      t.string :password
      t.string :uuid
      t.json :parameters

      t.timestamps
    end
  end
end

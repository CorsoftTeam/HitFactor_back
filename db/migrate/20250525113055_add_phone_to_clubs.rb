class AddPhoneToClubs < ActiveRecord::Migration[7.2]
  def change
    add_column :clubs, :phone, :string
  end
end

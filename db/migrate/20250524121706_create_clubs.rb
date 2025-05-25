class CreateClubs < ActiveRecord::Migration[7.2]
  def change
    create_table :clubs do |t|
      t.string :name
      t.string :address
      t.string :open_time_workday
      t.string :close_time_workday
      t.string :open_time_weekend
      t.string :close_time_weekend

      t.timestamps
    end
  end
end

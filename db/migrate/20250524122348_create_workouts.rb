class CreateWorkouts < ActiveRecord::Migration[7.2]
  def change
    create_table :workouts do |t|
      t.time :start_time
      t.integer :coach_id, null: false
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :club, null: false, foreign_key: true
      t.boolean :need_gun, default: true
      t.boolean :open, default: true

      t.timestamps
    end
  end
end

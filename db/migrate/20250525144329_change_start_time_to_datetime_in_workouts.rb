class ChangeStartTimeToDatetimeInWorkouts < ActiveRecord::Migration[7.2]
  def change
    change_column :workouts, :start_time, :datetime
  end
end

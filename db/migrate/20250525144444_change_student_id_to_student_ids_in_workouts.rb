class ChangeStudentIdToStudentIdsInWorkouts < ActiveRecord::Migration[7.2]
  def change_column
    change_column :workouts, :student_id, :integer
  end
end

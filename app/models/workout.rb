class Workout < ApplicationRecord
  has_one :coach, class_name: "User", foreign_key: "coach_id"
  has_one :student, class_name: "User", foreign_key: "student_id"
  belongs_to :club
end

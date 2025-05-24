class Workout < ApplicationRecord
  has_one :coach, class_name: "User", foreign_key: "coach_id"
  has_many :students, class_name: "User", foreign_key: "student_ids"
  has_one :club
end

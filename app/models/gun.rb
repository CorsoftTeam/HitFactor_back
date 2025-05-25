class Gun < ApplicationRecord
  self.inheritance_column = nil
  belongs_to :user
  has_one_attached :sound

  GUN_TYPES = [ 'self_defence', 'pistol', 'pcc', 'carbine', 'shotgun', 'bolt_action' ]

  validate :validate_gun_type

  def validate_gun_type
    GUN_TYPES.include?(self.gun_type)
  end
end

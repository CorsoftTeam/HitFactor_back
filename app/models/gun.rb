class Gun < ApplicationRecord
  self.inheritance_column = nil
  belongs_to :user
  has_one_attached :sound

  GUN_TYPES = [ 'self_defence', 'pistol', 'pc', 'carbine', 'shotgun', 'гладкоствол', 'bolt_action' ]

  validate :real_gun_type

  def real_gun_type
    GUN_TYPES.include?(self.gun_type)
  end
end

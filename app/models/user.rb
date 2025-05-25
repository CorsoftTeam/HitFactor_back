class User < ApplicationRecord
  encrypts :password, deterministic: true

  has_many :guns
  has_one_attached :image

  def except(*keys)
    attributes.except(*keys.map(&:to_s))
  end
  
  def set_uuid
    self.update(uuid: SecureRandom.uuid)
  end

  def admin_for(club_id)
    self.parameters['admin_for']&.include?(club_id)
  end
  
  def coach_for(club_id)
    self.parameters['coach_for']&.include?(club_id)
  end
end

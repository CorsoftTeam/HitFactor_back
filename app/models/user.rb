class User < ApplicationRecord
  encrypts :password, deterministic: true

  has_many :guns
  has_one_attached :image

  validates :email, uniqueness: true
  validates :login, uniqueness: true
  validates :phone_number, uniqueness: true

  def except(*keys)
    attributes.except(*keys.map(&:to_s))
  end
  
  def set_uuid
    self.update(uuid: SecureRandom.uuid)
  end

  def admin_for?(club_id)
    self.update(parameters: {}) if self.parameters.nil? 
    Rails.logger.debug self.parameters['admin_for']
    Rails.logger.debug club_id.kind_of?(Integer)
    self.parameters['admin_for']&.include?(club_id.to_i)
  end
  
  def coach_for?(club_id)
    self.update(parameters: {}) if self.parameters.nil? 
    self.parameters['coach_for']&.include?(club_id.to_i)
  end
end

class User < ApplicationRecord
  encrypts :password, deterministic: true

  has_many :guns
  has_one_attached :image

  validates :email, uniqueness: true, unless: -> { email.nil? }
  validates :login, uniqueness: true
  validates :phone_number, uniqueness: true, unless: -> { phone_number.nil? }

  def except(*keys)
    attributes.except(*keys.map(&:to_s))
  end
  
  def set_uuid
    self.update(uuid: SecureRandom.uuid)
  end

  def admin_for?(club_id)
    self.update(parameters: {}) if self.parameters.nil? 
    Rails.logger.debug self.parameters['admin_for']&.include?(club_id.to_i)
    self.parameters['admin_for']&.include?(club_id.to_i)
  end
  
  def coach_for?(club_id)
    self.update(parameters: {}) if self.parameters.nil? 
    Rails.logger.debug self.parameters['admin_for']&.include?(club_id.to_i)
    self.parameters['coach_for']&.include?(club_id.to_i)
  end
end

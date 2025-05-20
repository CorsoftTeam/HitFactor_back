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
end

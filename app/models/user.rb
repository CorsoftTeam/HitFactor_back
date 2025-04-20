class User < ApplicationRecord
  encrypts :password, deterministic: true

  has_many :guns
  has_one_attached :image

  def set_uuid
    self.update(uuid: SecureRandom.uuid)
  end
end

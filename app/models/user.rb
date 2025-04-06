class User < ApplicationRecord
  encrypts :password, deterministic: true

  has_many :guns

  def set_uuid
    self.update(uuid: SecureRandom.uuid)
  end
end

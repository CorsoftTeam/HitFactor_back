class User < ApplicationRecord
  encrypts :password, deterministic: true

  def set_uuid
    self.update(uuid: SecureRandom.uuid)
  end
end

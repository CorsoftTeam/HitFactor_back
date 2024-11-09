class User < ApplicationRecord
  encrypts :password, deterministic: true
end

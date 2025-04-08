class User < ApplicationRecord

  # Validations
  validates :ip_address, presence: true, uniqueness: true
end

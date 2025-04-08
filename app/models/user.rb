class User < ApplicationRecord
  # Associations
  has_many :searches
  # Validations
  validates :ip_address, presence: true, uniqueness: true
end

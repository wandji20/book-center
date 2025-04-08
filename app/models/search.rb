class Search < ApplicationRecord
  # Validations
  validates :query, presence: true
  # Associations
  belongs_to :user
end

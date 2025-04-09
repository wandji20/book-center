class Search < ApplicationRecord
  # Validations
  validates :query, presence: true

  # Associations
  belongs_to :user

  scope :trending, -> {
    select('query, COUNT(*) as search_count')
      .group(:query)
      .order('search_count DESC')
      .limit(10)
  }
end

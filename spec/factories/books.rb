FactoryBot.define do
  factory :book do
    title { Faker::Book.unique.title }
    author { Faker::Book.author }
  end
end

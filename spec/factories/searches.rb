FactoryBot.define do
  factory :search do
    query { "MyString" }
    association :user
  end
end

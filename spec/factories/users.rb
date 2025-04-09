FactoryBot.define do
  factory :user do
    ip_address { Faker::Internet.unique.uuid }
  end
end

FactoryGirl.define do
  factory :link do
    title { Faker::Lorem.sentence }
    url   { Faker::Internet.url }
  end
end

FactoryGirl.define do
  factory :link do
    feed
    title { Faker::Lorem.sentence }
    url   { Faker::Internet.url }
  end
end

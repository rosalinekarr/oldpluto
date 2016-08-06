FactoryGirl.define do
  factory :feed do
    title { Faker::Lorem.word }
    url   { Faker::Internet.url }
  end
end

FactoryGirl.define do
  factory :advertisement do
    title { Faker::Lorem.sentence }
    url   { Faker::Internet.url }
  end
end

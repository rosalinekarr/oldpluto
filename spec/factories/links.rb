FactoryGirl.define do
  factory :link do
    feed
    title        { Faker::Lorem.sentence }
    url          { Faker::Internet.url }
    published_at { Faker::Time.backward(7) }
  end
end

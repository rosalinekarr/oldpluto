FactoryGirl.define do
  factory :share do
    user
    link
    network { %w( facebook twitter google reddit tumblr pinterest linkedin
                  buffer digg stumbleupon delicious ).sample }
  end
end

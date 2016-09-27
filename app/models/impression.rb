class Impression < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true
end

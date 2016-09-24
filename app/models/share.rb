class Share < ApplicationRecord
  belongs_to :user
  belongs_to :link, dependent: :destroy, counter_cache: true
end

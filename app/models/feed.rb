class Feed < ApplicationRecord
  validates :title, :url, presence: true
  validates :title, :url, uniqueness: true
end

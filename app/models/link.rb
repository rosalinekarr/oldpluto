class Link < ApplicationRecord
  belongs_to :feed

  validates :title, :url, :feed_id, presence: true
  validates :title, :url, uniqueness: true
end

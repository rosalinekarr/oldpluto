class Link < ApplicationRecord
  belongs_to :feed

  validates :title, :url, presence: true
  validates :title, :url, uniqueness: true
end

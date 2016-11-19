class Author < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true
  validates :slug, uniqueness: true

  friendly_id :name, use: :slugged
end

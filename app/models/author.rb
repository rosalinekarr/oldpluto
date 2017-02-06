class Author < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true
  validates :slug, uniqueness: true

  friendly_id :name, use: :slugged

  def score
    return 0.0 if links.sum(:impressions_count).zero?
    links.sum(:clicks_count) / links.sum(:impressions_count)
  end
end

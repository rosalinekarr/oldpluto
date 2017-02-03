class Author < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true
  validates :slug, uniqueness: true

  friendly_id :name, use: :slugged

  def points
    @points ||= ['clicks', 'shares', 'favorites'].reduce(0) do |sum, column|
      sum + links.sum("#{column}_count".to_sym)
    end
  end

  def score
    @score ||= (points.to_f + 1.0) / (links.sum(:impressions_count).to_f + 1.0)
  end
end

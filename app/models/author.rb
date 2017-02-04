class Author < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true
  validates :slug, uniqueness: true

  friendly_id :name, use: :slugged

  def points
    @points ||= %w( clicks shares favorites ).reduce(0) do |sum, column|
      sum + links.sum("#{column}_count".to_sym)
    end
  end

  def average_click_through_rate
    return 0.0 if links.sum(:impressions_count).zero?
    links.sum(:clicks_count) / links.sum(:impressions_count)
  end

  def score
    @score ||= (points.to_f + 1.0) / (links.sum(:impressions_count).to_f + 1.0)
  end
end

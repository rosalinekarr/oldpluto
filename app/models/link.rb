class Link < ApplicationRecord
  TTL = 1.week

  include AlgoliaSearch

  delegate :title, to: :feed, prefix: true

  has_many   :clicks,      dependent: :destroy
  has_many   :shares,      dependent: :destroy
  has_many   :favorites,   dependent: :destroy
  has_many   :users,       through: :favorites
  belongs_to :author,      counter_cache: true
  belongs_to :feed,        counter_cache: true

  validates :title, :url, :feed_id, presence: true
  validates :title, :url, uniqueness: true

  after_create :index!
  after_create :set_expiration

  algoliasearch auto_index: false, auto_remove: false, per_environment: true do
    attribute :body, :points, :published_at_i, :score, :title
    tags do
      author_tag = "author_#{author.name.parameterize}" if author.try(:name).present?
      source_tag = "source_#{feed.slug.parameterize}"
      [author_tag, source_tag].compact
    end
    customRanking ['desc(score)']

    add_replica 'popular', per_environment: true do
      customRanking ['desc(points)']
    end

    add_replica 'newest', per_environment: true do
      customRanking ['desc(published_at_i)']
    end
  end

  def favorited?(user)
    Favorite.where(user: user, link: self).any?
  end

  def points
    @points ||= clicks_count + shares_count + favorites_count
  end

  def score
    @score ||= begin
      author_score = author.try(:score) || 1.0
      (published_at.to_f * feed.score * author_score * points.to_f).to_i
    end
  end

  def published_at_i
    published_at.to_i
  end

  private

  def set_expiration
    DestroyLinkJob.set(wait_until: (published_at + TTL)).perform_later(self.id)
  end
end

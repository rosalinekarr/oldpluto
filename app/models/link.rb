class Link < ApplicationRecord
  CLICK_SCORE_WEIGHT      = ENV['CLICK_SCORE_WEIGHT']      || 1.0
  SHARE_SCORE_WEIGHT      = ENV['SHARE_SCORE_WEIGHT']      || 2.0
  FAVORITE_SCORE_WEIGHT   = ENV['FAVORITE_SCORE_WEIGHT']   || 5.0
  IMPRESSION_SCORE_WEIGHT = ENV['IMPRESSION_SCORE_WEIGHT'] || -1.0
  AUTHOR_SCORE_WEIGHT     = ENV['AUTHOR_SCORE_WEIGHT']     || 0.2
  FEED_SCORE_WEIGHT       = ENV['FEED_SCORE_WEIGHT']       || 0.1
  TTL                     = ENV['LINK_TTL']                || 1.week

  include AlgoliaSearch

  delegate :title, to: :feed, prefix: true

  has_many   :clicks,      dependent: :destroy
  has_many   :impressions, dependent: :destroy
  has_many   :shares,      dependent: :destroy
  has_many   :favorites,   dependent: :destroy
  has_many   :users,       through: :favorites
  belongs_to :author,      counter_cache: true
  belongs_to :feed,        counter_cache: true

  validates :title, :url, :feed_id, presence: true
  validates :title, :url, uniqueness: true

  after_create :index_later
  after_create :set_expiration

  algoliasearch auto_index: false, auto_remove: false, per_environment: true do
    attribute :title, :body, :points, :score_i, :published_at_i, :click_through_rate_i
    tags do
      author_tag = "author_#{author.name.parameterize}" if author.try(:name).present?
      source_tag = "source_#{feed.slug.parameterize}"
      [author_tag, source_tag].compact
    end
    customRanking ['desc(score_i)']

    add_replica 'rising', per_environment: true do
      customRanking ['desc(click_through_rate_i)']
    end

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
    clicks_count + shares_count + favorites_count
  end

  def click_through_rate
    return 0.0 if impressions_count.zero?
    clicks_count.to_f / impressions_count.to_f
  end

  def click_through_rate_i
    (click_through_rate * 1000.0).to_i
  end

  def score
    score =  clicks_count      ** CLICK_SCORE_WEIGHT
    score *= shares_count      ** SHARE_SCORE_WEIGHT
    score *= favorites_count   ** FAVORITE_SCORE_WEIGHT
    score *= impressions_count ** IMPRESSION_SCORE_WEIGHT
    score *= author.score      ** AUTHOR_SCORE_WEIGHT
    score *= feed.score        ** FEED_SCORE_WEIGHT
    score
  end

  def score_i
    (score * 1000.0).to_i
  end

  def published_at_i
    published_at.to_i
  end

  def index_later
    return if indexing || (last_indexed_at || Time.now) > 1.day.ago
    IndexLinkJob.perform_later id
    update_columns(indexing: true)
  end

  private

  def set_expiration
    DestroyLinkJob.set(wait_until: (published_at + TTL)).perform_later(self.id)
  end
end

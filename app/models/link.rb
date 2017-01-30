require 'htmlentities'

class Link < ApplicationRecord
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

  before_validation :sanitize_attributes
  before_validation :fix_post_dated_links
  after_create      :set_expiration

  algoliasearch enqueue: :start_index_job, per_environment: true do
    attribute :age, :body, :points, :score, :title
    tags do
      author_tag = "author_#{author.name.parameterize}" if author.try(:name).present?
      source_tag = "source_#{feed.slug.parameterize}"
      [author_tag, source_tag].compact
    end
    customRanking ['asc(score)', 'asc(age)']

    add_replica 'popular', per_environment: true do
      customRanking ['desc(points)', 'asc(age)']
    end

    add_replica 'newest', per_environment: true do
      customRanking ['asc(age)', 'desc(points)']
    end
  end

  def self.start_index_job(record, remove=false)
    SearchIndexJob.perform_later(record.id, remove)
  end

  def favorited?(user)
    Favorite.where(user: user, link: self).any?
  end

  def points
    clicks_count + shares_count + favorites_count
  end

  def age
    Time.now - published_at
  end

  def score
    (age.to_i * feed.links_count) / (points + 1)
  end

  private

  def fix_post_dated_links
    self.published_at = [published_at, DateTime.now].compact.min
  end

  def sanitize_attributes
    self.title = ActionController::Base.helpers.strip_tags(title)
    self.body  = ActionController::Base.helpers.strip_tags(body)

    self.title = HTMLEntities.new.decode(title)
    self.body  = HTMLEntities.new.decode(body)
  end

  def set_expiration
    DestroyLinkJob.set(wait: 7.days).perform_later(self.id)
  end
end

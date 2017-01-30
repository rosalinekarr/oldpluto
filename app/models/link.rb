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
    attribute :title, :body, :clicks_count
    attribute :score do
      ((published_at - Time.now) / 86400).round / (clicks_count + 1)
    end
    attribute :published_at_i do
      published_at.to_i
    end
    tags do
      author_tag = "author_#{author.name.parameterize}" if author.try(:name).present?
      source_tag = "source_#{feed.slug.parameterize}"
      [author_tag, source_tag].compact
    end
    customRanking ['desc(score)']

    add_replica 'popular', per_environment: true do
      customRanking ['desc(clicks_count)', 'desc(published_at_i)']
    end

    add_replica 'newest', per_environment: true do
      customRanking ['desc(published_at_i)', 'desc(clicks_count)']
    end
  end

  def self.start_index_job(record, remove=false)
    SearchIndexJob.perform_later(record.id, remove)
  end

  def author_name=(name)
    name = ActionController::Base.helpers.strip_tags name
    self.author = Author.find_or_create_by(name: name)
  end

  def favorited?(user)
    Favorite.where(user: user, link: self).any?
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

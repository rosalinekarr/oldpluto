require 'htmlentities'

class Link < ApplicationRecord
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

  before_validation :sanitize_attributes
  before_validation :fix_post_dated_links
  after_create      :increment_word_counts
  after_create      :set_expiration

  scope :search, -> (terms) {
    terms.inject(self) do |query, term|
      expression = "%#{term}%"
      query.where('links.title LIKE ? OR links.body LIKE ?', expression, expression)
    end
  }
  scope :since, -> (t) { where('published_at > ?', t.hours.ago) if t.present? }
  scope :authored_by, -> (ids) {
    includes(:author).where(authors: { slug: ids }).references(:author) if ids.any?
  }
  scope :from_feeds, -> (ids) {
    includes(:feed).where(feeds: { slug: ids }).references(:feed) if ids.any?
  }

  def self.tag_ttl
    @tag_ttl ||= (30000 / $redis.dbsize.to_i)
  end

  def author_name=(name)
    name = ActionController::Base.helpers.strip_tags name
    self.author = Author.find_or_create_by(name: name)
  end

  def favorited?(user)
    Favorite.where(user: user, link: self).any?
  end

  def tags
    @tags ||= begin
      key = "en-US:#{id}"
      unless $redis.exists(key)
        words = [title, body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
        $redis.zadd(key, words.uniq.map{ |word| [words.count(word), word] })
        $redis.zinterstore(key, ['en-US', key], aggregate: 'max')
        $redis.expire(key, Link.tag_ttl)
      end
      $redis.zrangebyscore(key, 2, '+inf', limit: [0, 5])
    end
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

  def increment_word_counts
    words = [title, body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
    return if words.empty?
    $redis.zadd("en-US:#{id}", words.uniq.map{ |word| [words.count(word), word] })
    $redis.expire("en-US:#{id}", Link.tag_ttl)
    $redis.zunionstore('en-US', ['en-US', "en-US:#{id}"])
  end

  def set_expiration
    DestroyLinkJob.set(wait: 7.days).perform_later(self.id)
  end
end

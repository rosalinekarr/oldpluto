require 'htmlentities'

class Link < ApplicationRecord
  BLACKLISTED_TAGS = YAML.load_file(Rails.root.join('config', 'tags', 'blacklist.yml'))

  acts_as_taggable

  delegate :title, to: :feed, prefix: true

  belongs_to :feed

  validates :title, :url, :feed_id, presence: true
  validates :title, :url, uniqueness: true

  before_validation :sanitized_title
  before_validation :sanitized_body
  after_create :extract_tags

  default_scope { includes(:feed) }

  def self.from_entry(entry, feed)
    return if Link.where(url: entry.url).any?
    Link.create(title:        entry.title,
                url:          entry.url,
                body:         entry.content || entry.summary || entry.title,
                published_at: [entry.published, DateTime.now].compact.min,
                feed:         feed)
  end

  def display_tags
    cache_key = "links/#{id}/display_tags"
    @display_tags ||= Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      tags.select { |t|
        t.taggings_count > 1
      }.sort{ |t|
        t.taggings_count
      }.first(5).collect(&:name)
    end
  end

  private

  def sanitized_title
    # Remove html tags
    self.title = ActionController::Base.helpers.strip_tags(title)
    # Convert html entities to unicode
    self.title = HTMLEntities.new.decode(title)
  end

  def sanitized_body
    # Remove html tags
    self.body = ActionController::Base.helpers.strip_tags(body)
    # Convert html entities to unicode
    self.body = HTMLEntities.new.decode(body)
  end

  def extract_tags
    # Fetch all capitalized words from the body
    tags = body.scan(/\b([A-Z][\w\-]+([\s\-][A-Z]\w+)*)\b/).map(&:first)
    # Set tags filtering with the tag blacklist
    self.tag_list = tags.select{ |tag| !BLACKLISTED_TAGS.include? tag.downcase }
  end
end

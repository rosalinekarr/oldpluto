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

  def display_tags
    # Get all tags that exist on other links as well
    @display_tags ||= tags.where('taggings_count > 1').pluck(:name)
  end

  private

  def sanitized_title
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

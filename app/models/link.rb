require 'htmlentities'

class Link < ApplicationRecord
  BLACKLISTED_TAGS = YAML.load_file(Rails.root.join('config', 'tags', 'blacklist.yml'))

  acts_as_taggable

  delegate :title, to: :feed, prefix: true

  has_many :clicks,      dependent: :destroy
  has_many :impressions, dependent: :destroy
  has_many :shares,      dependent: :destroy
  belongs_to :feed,      counter_cache: true

  validates :title, :url, :feed_id, presence: true
  validates :title, :url, uniqueness: true

  before_validation :sanitized_attributes
  after_create :extract_tags
  after_create :set_expiration

  def display_tags
    tags.sort_by{ |tag| -tag.taggings_count }.first(5).collect(&:name)
  end

  private

  def sanitized_attributes
    # Remove html tags
    self.title = ActionController::Base.helpers.strip_tags(title)
    self.body = ActionController::Base.helpers.strip_tags(body)
    # Convert html entities to unicode
    self.title = HTMLEntities.new.decode(title)
    self.body = HTMLEntities.new.decode(body)
  end

  def extract_tags
    # Fetch all capitalized words from the title
    tags = [title, body].join(' ').scan(/[A-Za-z]+/).map(&:downcase).uniq
    # Set tags filtering with the tag blacklist
    self.tag_list = tags.reject{ |tag| BLACKLISTED_TAGS.include? tag }
  end

  def set_expiration
    DestroyLinkJob.set(wait: 7.days).perform_later(self.id)
  end
end

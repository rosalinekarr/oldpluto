class Link < ApplicationRecord
  acts_as_taggable

  delegate :title, to: :feed, prefix: true

  belongs_to :feed

  validates :title, :url, :feed_id, presence: true
  validates :title, :url, uniqueness: true

  before_validation :sanitized_body
  after_create :extract_tags

  default_scope { includes(:feed) }

  private

  def sanitized_body
    # Strip html entities
    self.body = body.gsub(/&[0-9#]+;/, '')

    # Strip html tags
    self.body = body.gsub(/\<[^\>]+\>/, '')

    # Strip non-ascii characters
    self.body = body.gsub(/[^[:ascii:]]/, '')

    # Collapse whitespace
    self.body = body.gsub(/\s+/, ' ')
  end

  def extract_tags
    # Set tags with all capitalized words from body
    self.tag_list = body.scan(/\b([A-Z][\w\-]+([\s\-][A-Z]\w+)*)\b/).map(&:first)
  end
end

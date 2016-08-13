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
    # Tag all proper nouns in the body
    tags = Brill::Tagger.new.tag(body)
    self.tag_list = tags.select{ |t| t[1] == 'NNP' }.map{ |t| t[0] }
  end
end

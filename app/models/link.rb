class Link < ApplicationRecord
  acts_as_taggable

  delegate :title, to: :feed, prefix: true

  belongs_to :feed

  validates :title, :url, :feed_id, presence: true
  validates :title, :url, uniqueness: true

  after_create :extract_tags

  default_scope { includes(:feed) }

  private

  def extract_tags
    sanitized_body = body.gsub(/[^\s\w]+/, '')
    tags = Brill::Tagger.new.tag(sanitized_body)
    tag_list = tags.select{ |t| t[1] == 'NNP' }.map{ |t| t[0] }
  end
end

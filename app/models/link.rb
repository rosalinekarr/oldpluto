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
    tagger = Brill::Tagger.new
    tags = tagger.tag(body).each do |term|
      tag_list.add(term[0]) if term[1] == 'NNP'
    end
  end
end

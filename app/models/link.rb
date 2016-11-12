require 'htmlentities'

class Link < ApplicationRecord
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

  private

  def corpus
    [title, body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
  end

  def sanitized_attributes
    self.title = ActionController::Base.helpers.strip_tags(title)
    self.body  = ActionController::Base.helpers.strip_tags(body)

    self.title = HTMLEntities.new.decode(title)
    self.body  = HTMLEntities.new.decode(body)
  end

  def extract_tags
    self.tag_list = corpus.uniq.sort_by{ |tag|
      local_count = corpus.count tag
      global_count = $redis.incrby(tag, local_count)
      global_count.to_f / local_count
    }.first(10)
  end

  def set_expiration
    DestroyLinkJob.set(wait: 7.days).perform_later(self.id)
  end
end

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
  after_create :increment_word_counts
  after_create :set_expiration
  after_save :extract_tags

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

  def increment_word_counts
    corpus.each{ |tag| $redis.incr(tag) }
  end

  def extract_tags
    self.tag_list = corpus.uniq.sort_by{ |tag|
      $redis.get(tag).to_f / corpus.count(tag)
    }.first(10)
  end

  def set_expiration
    DestroyLinkJob.set(wait: 7.days).perform_later(self.id)
  end
end

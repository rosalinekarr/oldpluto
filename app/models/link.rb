require 'htmlentities'

class Link < ApplicationRecord
  acts_as_taggable

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

  before_validation :sanitized_attributes
  before_save       :set_score
  after_create      :increment_word_counts
  after_create      :set_expiration
  after_save        :update_tags

  def author_name=(name)
    name = ActionController::Base.helpers.strip_tags name
    self.author = Author.find_or_create_by(name: name)
  end

  def corpus
    [title, body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
  end

  def favorited?(user)
    Favorite.where(user: user, link: self).any?
  end

  private

  def set_score
    word_scores = corpus.map do |tag|
      $redis.get("tags:#{tag}:click_count").try(:to_i) || 0
    end
    self.score = word_scores.sum
  end

  def sanitized_attributes
    self.title = ActionController::Base.helpers.strip_tags(title)
    self.body  = ActionController::Base.helpers.strip_tags(body)

    self.title = HTMLEntities.new.decode(title)
    self.body  = HTMLEntities.new.decode(body)
  end

  def increment_word_counts
    IncrementWordCountsJob.perform_later(self.id)
  end

  def update_tags
    UpdateLinkTagsJob.perform_later(self.id) if title_changed? || body_changed?
  end

  def set_expiration
    DestroyLinkJob.set(wait: 7.days).perform_later(self.id)
  end
end

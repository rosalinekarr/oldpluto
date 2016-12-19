class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create :increment_click_counts

  private

  def increment_click_counts
    link.corpus.each{ |tag, score| $redis.zincrby('clicks', score, tag) }
  end
end

class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create :increment_word_click_counts

  private

  def increment_word_click_counts
    link.corpus.each{ |tag| $redis.incr("tags:#{tag}:click_count") }
  end
end

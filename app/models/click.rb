class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create :increment_click_counts

  private

  def increment_click_counts
    return if link.corpus.empty?
    $redis.zadd('clicks:temp', link.corpus)
    $redis.zunionstore('clicks', ['clicks', 'clicks:temp'])
    $redis.expire('clicks:temp', 0)
  end
end

class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create :increment_click_counts

  private

  def increment_click_counts
    words = [link.title, link.body].join(' ')
                                   .scan(/[A-Za-z]+/)
                                   .map(&:downcase)
                                   .uniq
                                   .map{ |word| [1, word] }
    return if words.empty?
    $redis.zadd("clicks:#{id}", words)
    $redis.zunionstore('clicks', ['clicks', "clicks:#{id}"])
    $redis.expire("clicks:#{id}", 0)
  end
end

class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create :increment_click_counts

  private

  def increment_click_counts
    words = [link.title, link.body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
    return if words.empty?
    word_counts.uniq.map{ |word| [words.count(word), word] }
    $redis.zadd("clicks:#{id}", word_counts)
    $redis.zunionstore('clicks', ['clicks', "clicks:#{id}"])
    $redis.expire("clicks:#{id}", 0)
  end
end

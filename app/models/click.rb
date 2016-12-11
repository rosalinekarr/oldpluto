class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create   :increment_click_counts
  before_destroy :decrement_click_counts

  private

  def increment_click_counts
    words = [link.title, link.body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
    return if words.empty?
    word_counts = words.uniq.map{ |word| [words.count(word), word] }
    $redis.zadd("clicks:#{id}", word_counts)
    $redis.zunionstore('clicks', ['clicks', "clicks:#{id}"])
    $redis.expire("clicks:#{id}", 0)
    update_word_scores
  end

  def decrement_click_counts
    words = [link.title, link.body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
    return if words.empty?
    word_counts = words.uniq.map{ |word| [-words.count(word), word] }
    $redis.zadd("clicks:#{id}", word_counts)
    $redis.zunionstore('clicks', ['clicks', "clicks:#{id}"])
    $redis.expire("clicks:#{id}", 0)
    $redis.zremrangebyscore('clicks', 0, 0)
    update_word_scores
  end

  def update_word_scores
    click_counts = $redis.zrangebyscore('clicks', '-inf', '+inf', withscores: true)
    word_counts = $redis.zrangebyscore('corpus', '-inf', '+inf', withscores: true)
    corpus = Hash[*(word_counts.flatten)]
    scores = click_counts.map do |click_count|
      [click_count[1] * 1.0 / corpus[click_count[0]], click_count[0]]
    end
    return if scores.empty?
    $redis.expire('scores', 0)
    $redis.zadd('scores', scores)
  end
end

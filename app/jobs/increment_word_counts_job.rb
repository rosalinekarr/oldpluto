class IncrementSetCountsJob < ApplicationJob
  queue_as :tags

  def perform(set, words)
    word_counts = words.uniq.map{ |word| [words.count(word), word] }
    $redis.zadd("#{set}:temp", word_counts)
    $redis.zunionstore(set, [set, "#{set}:temp"])
    $redis.expire("#{set}:temp", 0)
    click_counts = $redis.zrangebyscore('clicks', '-inf', '+inf', withscores: true)
    word_counts = $redis.zrangebyscore('corpus', '-inf', '+inf', withscores: true)
    corpus = Hash[*(word_counts.flatten)]
    scores = click_counts.map do |click_count|
      [click_count[1] * 1.0 / corpus[click_count[0]], click_count[0]]
    end
    $redis.zadd('scores', scores)
  end
end

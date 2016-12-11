class UpdateTagScoresJob < ApplicationJob
  queue_as :tags

  def perform
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

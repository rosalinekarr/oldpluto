class Tag
  def self.update_tag_counts(set, words, weight=1)
    word_counts = words.uniq.map{ |word| [ weight * words.count(word), word ] }
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

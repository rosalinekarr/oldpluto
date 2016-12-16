class Tag
  def self.increment_tag_counts(words)
    Tag.update_set_counts('corpus', Tag.tags_from_words(words)) if words.any?
  end

  def self.decrement_tag_counts(words)
    Tag.update_set_counts('corpus', Tag.tags_from_words(words, -1)) if words.any?
  end

  def self.increment_click_counts(words)
    Tag.update_set_counts('clicks', Tag.tags_from_words(words)) if words.any?
  end

  def self.decrement_click_counts(words)
    Tag.update_set_counts('clicks', Tag.tags_from_words(words, -1)) if words.any?
  end

  def self.update_set_counts(set, counts)
    $redis.zadd("#{set}:temp", counts)
    $redis.zunionstore(set, [set, "#{set}:temp"])
    $redis.expire("#{set}:temp", 0)
    Tag.update_tag_scores!
  end

  def self.update_tag_scores!
    click_counts = $redis.zrangebyscore('clicks', '-inf', '+inf', withscores: true)
    word_counts = $redis.zrangebyscore('corpus', '-inf', '+inf', withscores: true)
    corpus = Hash[word_counts.each_slice(2).to_a]
    scores = click_counts.map do |count|
      [count[1] * 1.0 / (corpus[count[0]] || 1.0), count[0]]
    end
    $redis.zadd('scores', scores) if scores.any?
  end

  def self.tags_from_words(words, weight=1)
    words.uniq.map{ |word| [ weight * words.count(word), word ] }
  end
end

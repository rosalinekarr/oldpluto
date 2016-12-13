class Tag
  def self.increment_tag_counts(words)
    word_counts = words.uniq.map{ |word| [ words.count(word), word ] }
    Tag.update_set_counts('corpus', word_counts)
  end

  def self.decrement_tag_counts(words)
    word_counts = words.uniq.map{ |word| [ -words.count(word), word ] }
    Tag.update_set_counts('corpus', word_counts)
  end

  def self.increment_click_counts(words)
    word_counts = words.uniq.map{ |word| [ words.count(word), word ] }
    Tag.update_set_counts('clicks', word_counts)
  end

  def self.decrement_click_counts(words)
    word_counts = words.uniq.map{ |word| [ -words.count(word), word ] }
    Tag.update_set_counts('clicks', word_counts)
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
    corpus = Hash[*(word_counts.flatten)]
    scores = click_counts.map do |click_count|
      [click_count[1] * 1.0 / corpus[click_count[0]], click_count[0]]
    end
    $redis.zadd('scores', scores)
  end
end

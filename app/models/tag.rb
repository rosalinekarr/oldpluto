class Tag
  def self.increment_tag_counts(words)
    word_counts = words.uniq.map{ |word| [ words.count(word), word ] }
    Tag.update_set_counts('corpus', word_counts) if words.any?
  end

  def self.decrement_tag_counts(words)
    word_counts = words.uniq.map{ |word| [ -1 * words.count(word), word ] }
    Tag.update_set_counts('corpus', word_counts) if words.any?
  end

  def self.increment_click_counts(words)
    word_counts = words.uniq.map{ |word| [ words.count(word), word ] }
    Tag.update_set_counts('clicks', word_counts) if words.any?
  end

  def self.decrement_click_counts(words)
    word_counts = words.uniq.map{ |word| [ -1 * words.count(word), word ] }
    Tag.update_set_counts('clicks', word_counts) if words.any?
  end

  def self.update_set_counts(set, counts)
    $redis.zadd("#{set}:temp", counts)
    $redis.zunionstore(set, [set, "#{set}:temp"])
    $redis.expire("#{set}:temp", 0)
    click_counts = $redis.zrange('clicks', 0, -1, withscores: true)
    word_counts  = $redis.zrange('corpus', 0, -1, withscores: true)
    corpus = Hash[word_counts]
    scores = click_counts.map do |count|
      [count[1] * 1.0 / (corpus[count[0]] || 1.0), count[0]]
    end
    $redis.zadd('scores', scores) if scores.any?
  end
end

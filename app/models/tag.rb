class Tag
  def self.scores
    @scores ||= begin
      corpus = Hash[Tag.corpus]
      scores = Tag.clicks.sort_by do |word, score|
        score * 1.0 / (corpus[word] || 1.0)
      end
    end
  end

  def self.corpus
    @corpus ||= $redis.zrange('corpus', 0, -1, withscores: true)
  end

  def self.clicks
    @clicks ||= $redis.zrange('clicks', 0, -1, withscores: true)
  end

  def self.increment_tag_counts(words)
    Tag.update_set_counts('corpus', word_counts) if words.any?
  end

  def self.increment_click_counts(words)
    Tag.update_set_counts('clicks', word_counts) if words.any?
  end

  def self.update_set_counts(set, counts)
    $redis.zadd("#{set}:temp", counts)
    $redis.zunionstore(set, [set, "#{set}:temp"])
    $redis.expire("#{set}:temp", 0)
  end
end

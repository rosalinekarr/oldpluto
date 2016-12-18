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

  def self.from_words(words)
    Tag.scores.select{ |tag| words.include? tag[0] }
              .sort_by{ |tag| -tag[1] }
              .map{ |tag| tag[0] }
              .first(5)
  end

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
  end
end

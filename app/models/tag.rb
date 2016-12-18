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
    return if words.empty?
    $redis.zadd('corpus:temp', counts)
    $redis.zunionstore(set, [set, 'corpus:temp'])
    $redis.expire('corpus:temp', 0)
  end

  def self.increment_click_counts(words)
    return if words.empty?
    $redis.zadd('clicks:temp', counts)
    $redis.zunionstore(set, [set, 'clicks:temp'])
    $redis.expire('clicks:temp', 0)
  end
end

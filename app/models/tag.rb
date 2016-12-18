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
end

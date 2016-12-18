class Tag
  def self.scores
    @scores ||= begin
      clicks = $redis.zrange('clicks', 0, -1, withscores: true)
      corpus = Hash[$redis.zrange('corpus', 0, -1, withscores: true)]
      scores = clicks.sort_by do |word, score|
        score * 1.0 / (corpus[word] || 1.0)
      end
    end
  end
end

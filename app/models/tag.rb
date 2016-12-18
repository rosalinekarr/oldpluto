class Tag
  def self.scores
    @scores ||= begin
      clicks = $redis.zrange('clicks', 0, -1, withscores: true)
      corpus = Hash[$redis.zrange('corpus', 0, -1, withscores: true)]
      clicks.map do |word, score|
        [word, score * 1.0 / (corpus[word] || 1.0)]
      end
    end
  end
end

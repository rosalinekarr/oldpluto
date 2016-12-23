class Tag < ApplicationRecord
  def self.scores
    @scores ||= begin
      clicks = $redis.zrange('clicks', 0, -1, withscores: true)
      scores = clicks.map do |word, score|
        [word, score * 1.0 / ($redis.zscore('corpus', word) || 1.0)]
      end
      Hash[scores]
    end
  end

  def self.score_for(tag)
    Tag.scores[tag] || 0.0
  end
end

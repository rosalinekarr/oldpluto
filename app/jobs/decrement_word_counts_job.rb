class DecrementWordCountsJob < ApplicationJob
  queue_as :tags

  def perform(*words)
    word_counts = words.uniq.map{ |word| [-words.count(word), word] }
    $redis.zadd("corpus:temp", word_counts)
    $redis.zunionstore('corpus', ['corpus', "corpus:temp"])
    $redis.expire("corpus:temp", 0)
    UpdateTagScoresJob.perform_later
  end
end

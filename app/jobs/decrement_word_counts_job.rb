class DecrementSetCountsJob < ApplicationJob
  queue_as :tags

  def perform(set, words)
    word_counts = words.uniq.map{ |word| [-words.count(word), word] }
    $redis.zadd("#{set}:temp", word_counts)
    $redis.zunionstore(set, [set, "#{set}:temp"])
    $redis.expire("#{set}:temp", 0)
    UpdateTagScoresJob.perform_later
  end
end

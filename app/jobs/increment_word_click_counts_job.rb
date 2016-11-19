class IncrementWordClickCountsJob < ApplicationJob
  queue_as :trending

  def perform(link_id)
    link = Link.find(link_id)
    link.corpus.each{ |tag| $redis.incr("tags:#{tag}:click_count") }
  end
end

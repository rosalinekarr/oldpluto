class IncrementWordCountsJob < ApplicationJob
  queue_as :tagging

  def perform(link_id)
    link = Link.find(link_id)
    link.corpus.each{ |tag| $redis.incr("tags:#{tag}:count") }
  end
end

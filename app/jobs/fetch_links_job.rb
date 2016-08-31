class FetchLinksJob < ApplicationJob
  MAX_DELAY = 4320 # Minutes in 3 days
  MIN_DELAY = 5

  queue_as :default

  def perform(feed_id, delay)
    count = Feed.find(feed_id).fetch
    new_delay = (count > 0) ? (delay.to_f / count).ceil : (delay * 2)
    new_delay = [[new_delay, MAX_DELAY].min, MIN_DELAY].max
    FetchLinksJob.set(wait: new_delay.minutes).perform_later(feed_id, new_delay)
  end
end

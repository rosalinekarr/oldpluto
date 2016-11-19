class FetchLinksJob < ApplicationJob
  MAX_DELAY = 259200 # Minutes in 3 days
  MIN_DELAY = 300

  queue_as :fetch

  def perform feed_id
    feed = Feed.find(feed_id)
    feed.fetch
    delay = [[feed.publish_rate, MIN_DELAY.seconds].max, MAX_DELAY.seconds].min
    FetchLinksJob.set(wait: delay).perform_later feed_id
  end
end

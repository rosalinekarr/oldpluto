class FetchLinksJob < ApplicationJob
  MAX_DELAY = 3.days
  MIN_DELAY = 5.minutes

  rescue_from(Feedjira::NoParserAvailable) do
    retry_job wait: MAX_DELAY
  end

  rescue_from(Feedjira::FetchFailure) do
    retry_job wait: MAX_DELAY
  end

  rescue_from(Faraday::ConnectionFailed) do
    retry_job wait: MAX_DELAY
  end

  queue_as :fetch

  def perform feed_id
    feed = Feed.find(feed_id)
    feed.fetch
    delay = [[feed.publish_rate, MIN_DELAY].max, MAX_DELAY].min
    FetchLinksJob.set(wait: delay).perform_later feed_id
  end
end

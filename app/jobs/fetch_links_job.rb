class FetchLinksJob < ApplicationJob
  queue_as :default

  def perform(feed_id, frequency)
    count = Feed.find(feed_id).fetch
    new_frequency = (count > 0) ? (frequency.to_f / count).ceil : (frequency * 2)
    FetchLinksJob.set(wait: new_frequency.minutes).perform_later(feed_id, new_frequency)
  end
end

class FetchLinksJob < ApplicationJob
  queue_as :default

  def perform(feed_id)
    Feed.find(feed_id).fetch
  end
end

class Feed < ApplicationRecord
  validates :title, :url, presence: true
  validates :title, :url, uniqueness: true

  before_create :set_title

  private

  def set_title
    feed = Feedjira::Feed.fetch_and_parse url
    self.title = feed.title
  end
end

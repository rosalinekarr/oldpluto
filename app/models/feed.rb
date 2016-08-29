class Feed < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :slug, :title, :url, presence: true
  validates :slug, :title, :url, uniqueness: true

  after_create :start_fetching
  before_validation :set_title

  friendly_id :title, use: :slugged

  def fetch
    begin
      feed.entries.map{ |entry| Link.from_entry(entry, self) }.compact.count
    rescue Faraday::ConnectionFailed
      0
    rescue FaradayMiddleware::RedirectLimitReached
      0
    rescue Feedjira::FetchFailure
      0
    end
  end

  private

  def start_fetching
    FetchLinksJob.set(wait: 1.minute).perform_later(id, 1)
  end

  def set_title
    self.title ||= feed.title
  end

  def feed
    @feed ||= Feedjira::Feed.fetch_and_parse(url)
  end
end

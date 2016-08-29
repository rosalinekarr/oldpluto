class Feed < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :slug, :title, :url, presence: true
  validates :slug, :title, :url, uniqueness: true

  before_validation :set_title

  friendly_id :title, use: :slugged

  def self.fetch_all
    Feed.find_each do |feed|
      FetchLinksJob.set(wait: feed.frequency.minutes).perform_later(feed.id)
    end
  end

  def fetch
    begin
      count = feed.entries.map{ |entry| Link.from_entry(entry, self) }.compact.count
      update(frequency: (count > 1) ? (frequency.to_f / count).ceil : (frequency * 2))
    rescue Faraday::ConnectionFailed
      update(frequency: frequency * 2)
    rescue FaradayMiddleware::RedirectLimitReached
      update(frequency: frequency * 2)
    end
  end

  private

  def set_title
    self.title ||= feed.title
  end

  def feed
    @feed ||= Feedjira::Feed.fetch_and_parse(url)
  end
end

class Feed < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :slug, :title, :url, presence: true
  validates :slug, :title, :url, uniqueness: true

  after_create :start_fetching
  before_validation :set_title

  friendly_id :title, use: :slugged

  def fetch
    old_count = links.count
    feed.entries.each do |entry|
      link = Link.find_or_initialize_by(url: entry.url)
      link.feed = self
      link.title = entry.title
      link.body = entry.content || entry.summary || entry.title
      link.published_at ||= [entry.published, DateTime.now].compact.min
      link.save
    end
    links.reload.count - old_count
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

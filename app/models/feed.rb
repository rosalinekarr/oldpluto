class Feed < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :slug, :title, :url, presence: true
  validates :slug, :title, :url, uniqueness: true

  after_create :start_fetching
  before_validation :set_title

  friendly_id :title, use: :slugged

  def fetch
    feed.entries.each do |entry|
      link = Link.find_or_initialize_by(url: entry.url)
      link.feed = self
      link.title = entry.title
      link.guid = entry.entry_id || entry.url
      link.body = entry.content || entry.summary || entry.title

      # Set author
      author_name = ActionController::Base.helpers.strip_tags entry.author
      link.author = Author.find_or_create_by(name: author_name)

      link.published_at ||= [entry.published, last_fetched_at].compact.max
      link.save
    end
    update(last_fetched_at: DateTime.now)
  end

  def publish_rate
    7.days / (links_count + 1)
  end

  private

  def start_fetching
    FetchLinksJob.perform_later id
  end

  def set_title
    self.title ||= feed.title
  end

  def feed
    @feed ||= Feedjira::Feed.fetch_and_parse(url)
  end
end

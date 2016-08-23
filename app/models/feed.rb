class Feed < ApplicationRecord
  extend FriendlyId

  has_many :links, dependent: :destroy

  validates :slug, :title, :url, presence: true
  validates :slug, :title, :url, uniqueness: true

  before_validation :set_title

  friendly_id :title, use: :slugged

  def self.fetch_all
    Feed.find_each { |feed| feed.fetch }
  end

  def fetch
    feed.entries.each do |entry|
      next if Link.where(url: entry.url).any?
      Link.create(title:        entry.title,
                  url:          entry.url,
                  body:         entry.content || entry.summary || entry.title,
                  published_at: entry.published || DateTime.now,
                  feed:         self)
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

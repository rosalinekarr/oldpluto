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
      link = self.links.find_or_initialize_by(url: entry.url)
      link.title = entry.title
      link.save
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

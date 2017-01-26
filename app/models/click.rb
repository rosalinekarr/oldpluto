class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create :increment_click_counts

  private

  def increment_click_counts
    corpus = (link.title.scan(/\w+/) + link.body.scan(/\w+/))
    link.tags.each{ |tag| tag.increment!(:click, corpus.count(tag.name)) }
  end
end

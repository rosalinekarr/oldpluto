class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create   :increment_click_counts
  before_destroy :decrement_click_counts

  private

  def increment_click_counts
    Tag.increment_click_counts(link.title.scan(/[A-Za-z]+/))
    Tag.increment_click_counts(link.body.scan(/[A-Za-z]+/))
  end

  def decrement_click_counts
    Tag.decrement_click_counts(link.title.scan(/[A-Za-z]+/))
    Tag.decrement_click_counts(link.body.scan(/[A-Za-z]+/))
  end
end

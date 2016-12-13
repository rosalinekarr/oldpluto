class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create   :increment_click_counts
  before_destroy :decrement_click_counts

  private

  def increment_click_counts
    words = [link.title, link.body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
    Tag.increment_click_counts(words) if words.any?
  end

  def decrement_click_counts
    words = [link.title, link.body].join(' ').scan(/[A-Za-z]+/).map(&:downcase)
    Tag.decrement_click_counts(words) if words.any?
  end
end

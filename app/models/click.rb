class Click < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create :increment_word_click_counts

  private

  def increment_word_click_counts
    IncrementWordClickCountsJob.perform_later(link_id)
  end
end

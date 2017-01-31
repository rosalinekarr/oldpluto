class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_save :update_search_index

  private

  def update_search_index
    Link.start_index_job(link)
  end
end

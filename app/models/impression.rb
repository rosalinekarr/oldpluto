class Impression < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  after_create :reindex_link

  private

  def reindex_link
    link.index!
  end
end

class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :link, counter_cache: true

  before_destroy :delete_link_if_expired

  private

  def delete_link_if_expired
    link.destroy if link.favorites_count < 2 && link.published_at < Link::TTL.ago
  end
end

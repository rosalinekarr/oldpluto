class DestroyLinkJob < ApplicationJob
  queue_as :cleanup

  def perform(link_id)
    Algolia::Index.new("Link_#{Rails.env}").delete_object(link_id)
    link = Link.find(link_id)
    link.destroy if link.favorites.empty?
  end
end

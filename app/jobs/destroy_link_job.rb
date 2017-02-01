class DestroyLinkJob < ApplicationJob
  queue_as :cleanup

  def perform(link_id)
    Algolia::Index.new("Link_#{Rails.env}").delete_object(link_id)
    Link.find(link_id).destroy
  end
end

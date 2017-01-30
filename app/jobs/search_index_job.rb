class SearchIndexJob < ApplicationJob
  queue_as :search

  def perform(link_id, remove)
    if remove
      Algolia::Index.new("Link_#{Rails.env}").delete_object(id)
    else
      Link.find(link_id).index!
    end
  end
end

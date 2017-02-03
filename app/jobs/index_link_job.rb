class IndexLinkJob < ApplicationJob
  queue_as :search

  def perform(link_id)
    link = Link.where(id: link_id).first
    return unless link.present?
    link.index!
    link.update_columns(indexing: false)
  end
end

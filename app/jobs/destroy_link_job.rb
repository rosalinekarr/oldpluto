class DestroyLinkJob < ApplicationJob
  queue_as :cleanup

  def perform(link_id)
    Link.find(link_id).destroy
  end
end

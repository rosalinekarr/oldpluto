class DestroyLinkJob < ApplicationJob
  queue_as :default

  def perform(link_id)
    Link.find(link_id).destroy
  end
end

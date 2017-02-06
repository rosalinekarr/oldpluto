class CreateImpressionJob < ApplicationJob
  queue_as :search

  def perform(user_id, link_ids)
    ActiveRecord::Base.transaction do
      Link.where(id: link_ids).each do |link|
        Impression.create link: link, user_id: user_id
      end
    end
  end
end

class UpdateLinkTagsJob < ApplicationJob
  queue_as :default

  def perform(link_id)
    link = Link.find(link_id)
    link.tag_list = link.corpus.uniq.sort_by{ |tag|
      $redis.get(tag).to_f / link.corpus.count(tag)
    }.first(10)
    link.save
  end
end

class AddLinksCountToFeeds < ActiveRecord::Migration[5.0]
  def change
    add_column :feeds, :links_count, :integer, default: 0, null: false
    Feed.find_each { |feed| Feed.reset_counters(feed.id, :links) }
  end
end

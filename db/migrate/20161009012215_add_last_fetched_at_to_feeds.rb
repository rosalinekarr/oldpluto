class AddLastFetchedAtToFeeds < ActiveRecord::Migration[5.0]
  def change
    add_column :feeds, :last_fetched_at, :timestamp
  end
end

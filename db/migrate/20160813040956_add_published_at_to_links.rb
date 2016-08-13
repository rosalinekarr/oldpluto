class AddPublishedAtToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :published_at, :timestamp
  end
end

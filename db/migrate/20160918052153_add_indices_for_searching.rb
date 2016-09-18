class AddIndicesForSearching < ActiveRecord::Migration[5.0]
  def change
    add_index :links, :visits
    add_index :links, :shares
    add_index :links, :views
    add_index :links, :published_at
  end
end

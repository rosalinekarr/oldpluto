class AddLastIndexedAtToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :last_indexed_at, :timestamp
  end
end

class AddIndexingStatusToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :indexing, :boolean, default: false, null: false
  end
end

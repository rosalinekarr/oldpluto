class DropTaggings < ActiveRecord::Migration[5.0]
  def change
    drop_table :taggings
  end
end

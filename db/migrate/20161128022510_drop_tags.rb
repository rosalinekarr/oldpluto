class DropTags < ActiveRecord::Migration[5.0]
  def change
    drop_table :tags
  end
end

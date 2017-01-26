class AddCountAndClicksToTags < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :clicks, :integer, default: 0, null: false
    add_column :tags, :count, :integer, default: 0, null: false
  end
end

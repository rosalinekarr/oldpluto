class DropUnusedColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :links, :impressions_count, :integer
    remove_column :links, :score, :integer
  end
end

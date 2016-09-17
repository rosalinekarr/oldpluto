class AddViewsToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :views, :integer, default: 0, null: false
  end
end

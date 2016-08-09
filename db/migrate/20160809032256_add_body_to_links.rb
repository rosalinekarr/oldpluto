class AddBodyToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :body, :text
  end
end

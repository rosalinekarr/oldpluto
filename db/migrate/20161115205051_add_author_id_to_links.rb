class AddAuthorIdToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :author_id, :integer, index: true
  end
end

class AddGuidToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :guid, :string
  end
end

class AddUserIdToAdvertisements < ActiveRecord::Migration[5.0]
  def change
    add_column :advertisements, :user_id, :integer, null: false
  end
end

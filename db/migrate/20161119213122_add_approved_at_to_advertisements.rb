class AddApprovedAtToAdvertisements < ActiveRecord::Migration[5.0]
  def change
    add_column :advertisements, :approved_at, :timestamp
  end
end

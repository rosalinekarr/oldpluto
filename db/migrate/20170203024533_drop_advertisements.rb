class DropAdvertisements < ActiveRecord::Migration[5.0]
  def change
    drop_table :advertisements
  end
end

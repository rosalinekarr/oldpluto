class CreateShares < ActiveRecord::Migration[5.0]
  def change
    rename_column :links, :shares, :shares_count

    create_table :shares do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :link, foreign_key: true
      t.string :network

      t.timestamps
    end
  end
end

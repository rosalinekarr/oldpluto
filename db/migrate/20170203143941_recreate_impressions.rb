class RecreateImpressions < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :impressions_count, :integer, default: 0, null: false

    create_table :impressions do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :link, foreign_key: true

      t.timestamps
    end
  end
end

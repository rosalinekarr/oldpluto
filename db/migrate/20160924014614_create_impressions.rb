class CreateImpressions < ActiveRecord::Migration[5.0]
  def change
    rename_column :links, :views, :impressions_count

    create_table :impressions do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :link, foreign_key: true

      t.timestamps
    end
  end
end

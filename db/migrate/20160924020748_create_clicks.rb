class CreateClicks < ActiveRecord::Migration[5.0]
  def change
    rename_column :links, :visits, :clicks_count

    create_table :clicks do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :link, foreign_key: true

      t.timestamps
    end
  end
end

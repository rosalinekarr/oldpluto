class CreateFavorites < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :favorites_count, :integer

    create_table :favorites do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :link, foreign_key: true

      t.timestamps
    end
  end
end

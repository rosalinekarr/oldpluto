class CreateFeeds < ActiveRecord::Migration[5.0]
  def change
    create_table :feeds do |t|
      t.string :title, null: false
      t.string :url,   null: false

      t.timestamps
    end

    add_index :feeds, :title, unique: true
    add_index :feeds, :url, unique: true
  end
end

class CreateLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :links do |t|
      t.string :title, null: false
      t.string :url,   null: false

      t.timestamps
    end

    add_index :links, :title, unique: true
    add_index :links, :url, unique: true
  end
end

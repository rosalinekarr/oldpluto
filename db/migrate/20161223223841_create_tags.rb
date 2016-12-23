class CreateTags < ActiveRecord::Migration[5.0]
  def change
    create_table :tags do |t|
      t.string :name
      t.float  :score, null: false, default: 0

      t.timestamps
    end
    add_index :tags, :name, unique: true
  end
end

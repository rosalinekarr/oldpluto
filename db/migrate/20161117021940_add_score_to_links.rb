class AddScoreToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :score, :integer, default: 0, null: false
  end
end

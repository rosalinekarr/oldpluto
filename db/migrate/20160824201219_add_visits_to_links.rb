class AddVisitsToLinks < ActiveRecord::Migration[5.0]
  def change
    add_column :links, :visits, :integer, default: 0, null: false
  end
end

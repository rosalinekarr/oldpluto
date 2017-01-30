class FixFavoritesCounts < ActiveRecord::Migration[5.0]
  def change
    remove_column :links, :favorites_count, :integer
    add_column :links, :favorites_count, :integer, default: 0, null: false
    Link.find_each{ |l| Link.reset_counters(l.id, :favorites) }
  end
end

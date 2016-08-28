class AddFrequencyToFeeds < ActiveRecord::Migration[5.0]
  def change
    add_column :feeds, :frequency, :integer, default: 1, null: false
  end
end

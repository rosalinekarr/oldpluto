class RemoveFrequencyFromFeeds < ActiveRecord::Migration[5.0]
  def change
    remove_column :feeds, :frequency
  end
end

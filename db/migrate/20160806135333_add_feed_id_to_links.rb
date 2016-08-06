class AddFeedIdToLinks < ActiveRecord::Migration[5.0]
  def change
    add_reference :links, :feed, foreign_key: true
  end
end

class ChangeLinksTitleAndBodyToCitext < ActiveRecord::Migration[5.0]
  def change
    remove_index  :links, :title
    change_column :links, :title, :citext
    change_column :links, :body,  :citext
  end
end

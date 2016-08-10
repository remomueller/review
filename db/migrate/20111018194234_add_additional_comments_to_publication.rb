class AddAdditionalCommentsToPublication < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :additional_comments, :text
  end
end

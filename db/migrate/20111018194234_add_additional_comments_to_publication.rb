class AddAdditionalCommentsToPublication < ActiveRecord::Migration
  def change
    add_column :publications, :additional_comments, :text
  end
end

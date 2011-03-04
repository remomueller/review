class ReviewWritingGroupAddition < ActiveRecord::Migration
  def self.up
    add_column :user_publication_reviews, :writing_group_nomination, :string
  end

  def self.down
    remove_column :user_publication_reviews, :writing_group_nomination
  end
end

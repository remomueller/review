class ReviewWritingGroupAddition < ActiveRecord::Migration[4.2]
  def change
    add_column :user_publication_reviews, :writing_group_nomination, :string
  end
end

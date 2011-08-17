class ChangeDefaultForReviews < ActiveRecord::Migration
  def up
    change_column :user_publication_reviews, :status, :string, :null => true, :default => nil
  end

  def down
    change_column :user_publication_reviews, :status, :string, :null => false, :default => 'approved'
  end
end

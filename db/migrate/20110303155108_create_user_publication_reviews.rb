class CreateUserPublicationReviews < ActiveRecord::Migration
  def self.up
    create_table :user_publication_reviews do |t|
      t.integer :user_id
      t.integer :publication_id
      t.string :status, :null => false, :default => 'approved'
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :user_publication_reviews
  end
end

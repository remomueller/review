class CreateUserPublicationReviews < ActiveRecord::Migration[4.2]
  def change
    create_table :user_publication_reviews do |t|
      t.integer :user_id
      t.integer :publication_id
      t.string :status, null: false, default: 'approved'
      t.text :comment

      t.timestamps
    end
  end
end

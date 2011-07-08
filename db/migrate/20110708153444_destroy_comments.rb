class DestroyComments < ActiveRecord::Migration
  def self.up
    drop_table :comments
  end

  def self.down
    create_table :comments do |t|
      t.integer :user_id
      t.string :object_model
      t.integer :object_id
      t.text :description
      t.boolean :deleted, :null => false, :default => false

      t.timestamps
    end
  end
end

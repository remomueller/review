class DestroyComments < ActiveRecord::Migration[4.2]
  def change
    drop_table :comments do |t|
      t.integer :user_id
      t.string :object_model
      t.integer :object_id
      t.text :description
      t.boolean :deleted, null: false, default: false

      t.timestamps
    end
  end
end

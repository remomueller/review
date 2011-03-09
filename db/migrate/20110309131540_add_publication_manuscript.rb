class AddPublicationManuscript < ActiveRecord::Migration
  def self.up
    add_column :publications, :manuscript, :string
    add_column :publications, :manuscript_uploaded_at, :datetime
  end

  def self.down
    remove_column :publications, :manuscript
    remove_column :publications, :manuscript_uploaded_at
  end
end

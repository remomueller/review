class AddPublicationManuscript < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :manuscript, :string
    add_column :publications, :manuscript_uploaded_at, :datetime
  end
end

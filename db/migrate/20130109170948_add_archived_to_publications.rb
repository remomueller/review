class AddArchivedToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :archived, :boolean, null: false, default: false
  end
end

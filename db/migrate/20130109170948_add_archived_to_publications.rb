class AddArchivedToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :archived, :boolean, null: false, default: false
  end
end

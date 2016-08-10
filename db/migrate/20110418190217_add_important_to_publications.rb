class AddImportantToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :important, :boolean, default: false, null: false
  end
end

class RemoveImportantFromPublications < ActiveRecord::Migration[4.2]
  def change
    remove_column :publications, :important, :boolean, default: false, null: false
  end
end

class PublicationSecretaryNotes < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :secretary_notes, :text
  end
end

class PublicationSecretaryNotes < ActiveRecord::Migration
  def self.up
    add_column :publications, :secretary_notes, :text
  end

  def self.down
    remove_column :publications, :secretary_notes
  end
end

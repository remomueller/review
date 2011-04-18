class AddImportantToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :important, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :publications, :important
  end
end

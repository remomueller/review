class RemoveImportantFromPublications < ActiveRecord::Migration
  def self.up
    remove_column :publications, :important
  end

  def self.down
    add_column :publications, :important, :boolean, :default => false, :null => false
  end
end

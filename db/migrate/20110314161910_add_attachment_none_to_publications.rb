class AddAttachmentNoneToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :attachment_none, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :publications, :attachment_none
  end
end

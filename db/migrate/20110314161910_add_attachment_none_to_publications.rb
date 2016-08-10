class AddAttachmentNoneToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :attachment_none, :boolean, null: false, default: false
  end
end

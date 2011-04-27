class AddMoreAttachmentsToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :chat_data_other_attachment, :string
    add_column :publications, :attachment_chat_variables_attachment, :string
    add_column :publications, :attachment_ancillary_forms_attachment, :string
    add_column :publications, :attachment_other_attachment, :string
  end

  def self.down
    remove_column :publications, :chat_data_other_attachment
    remove_column :publications, :attachment_chat_variables_attachment
    remove_column :publications, :attachment_ancillary_forms_attachment
    remove_column :publications, :attachment_other_attachment
  end
end
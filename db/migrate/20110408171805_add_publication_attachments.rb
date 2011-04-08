class AddPublicationAttachments < ActiveRecord::Migration
  def self.up
    add_column :publications, :chat_data_main_forms_attachment, :string
    add_column :publications, :chat_data_main_database_attachment, :string
    add_column :publications, :attachment_chat_form_attachment, :string
  end

  def self.down
    remove_column :publications, :chat_data_main_forms_attachment
    remove_column :publications, :chat_data_main_database_attachment
    remove_column :publications, :attachment_chat_form_attachment
  end
end

class AddPublicationAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :chat_data_main_forms_attachment, :string
    add_column :publications, :chat_data_main_database_attachment, :string
    add_column :publications, :attachment_chat_form_attachment, :string
  end
end

class AddMoreAttachmentsToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :chat_data_other_attachment, :string
    add_column :publications, :attachment_chat_variables_attachment, :string
    add_column :publications, :attachment_ancillary_forms_attachment, :string
    add_column :publications, :attachment_other_attachment, :string
  end
end

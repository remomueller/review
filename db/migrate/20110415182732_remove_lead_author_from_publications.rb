class RemoveLeadAuthorFromPublications < ActiveRecord::Migration[4.2]
  def change
    remove_column :publications, :lead_author, :string
    remove_column :publications, :lead_author_id, :integer
  end
end

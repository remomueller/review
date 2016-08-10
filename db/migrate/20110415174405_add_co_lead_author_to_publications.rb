class AddCoLeadAuthorToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :lead_author_id, :integer
    add_column :publications, :co_lead_author_id, :integer
  end
end

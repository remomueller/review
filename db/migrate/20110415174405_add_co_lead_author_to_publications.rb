class AddCoLeadAuthorToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :lead_author_id, :integer
    add_column :publications, :co_lead_author_id, :integer
  end

  def self.down
    remove_column :publications, :lead_author_id
    remove_column :publications, :co_lead_author_id
  end
end

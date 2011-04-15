class RemoveLeadAuthorFromPublications < ActiveRecord::Migration
  def self.up
    remove_column :publications, :lead_author
    remove_column :publications, :lead_author_id
  end

  def self.down
    add_column :publications, :lead_author, :string
    add_column :publications, :lead_author_id, :integer
  end
end

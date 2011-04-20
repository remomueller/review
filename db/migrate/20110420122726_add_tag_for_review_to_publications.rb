class AddTagForReviewToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :tagged_for_pp_review, :boolean, :default => false, :null => false
    add_column :publications, :tagged_for_sc_review, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :publications, :tagged_for_pp_review
    remove_column :publications, :tagged_for_sc_review
  end
end

class AddTagForReviewToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :tagged_for_pp_review, :boolean, default: false, null: false
    add_column :publications, :tagged_for_sc_review, :boolean, default: false, null: false
  end
end

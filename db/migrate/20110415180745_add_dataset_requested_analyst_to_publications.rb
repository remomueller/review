class AddDatasetRequestedAnalystToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :dataset_requested_analyst, :text
  end
end

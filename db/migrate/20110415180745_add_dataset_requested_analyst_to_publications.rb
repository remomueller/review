class AddDatasetRequestedAnalystToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :dataset_requested_analyst, :text
  end

  def self.down
    remove_column :publications, :dataset_requested_analyst
  end
end

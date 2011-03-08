class PublicationProposedAnalysis < ActiveRecord::Migration
  def self.up
    add_column :publications, :proposed_analysis, :text
  end

  def self.down
    remove_column :publications, :proposed_analysis
  end
end

class PublicationProposedAnalysis < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :proposed_analysis, :text
  end
end

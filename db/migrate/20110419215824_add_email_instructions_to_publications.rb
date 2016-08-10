class AddEmailInstructionsToPublications < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :additional_ppcommittee_instructions, :text
    add_column :publications, :additional_sccommittee_instructions, :text
  end
end

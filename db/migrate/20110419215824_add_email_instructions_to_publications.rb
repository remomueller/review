class AddEmailInstructionsToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :additional_ppcommittee_instructions, :text
    add_column :publications, :additional_sccommittee_instructions, :text
  end

  def self.down
    remove_column :publications, :additional_ppcommittee_instructions
    remove_column :publications, :additional_sccommittee_instructions
  end
end

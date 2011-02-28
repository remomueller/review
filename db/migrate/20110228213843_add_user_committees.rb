class AddUserCommittees < ActiveRecord::Migration
  def self.up
    add_column :users, :pp_committee, :boolean, :null => false, :default => false
    add_column :users, :steering_committee, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :pp_committee
    remove_column :users, :steering_committee
  end
end

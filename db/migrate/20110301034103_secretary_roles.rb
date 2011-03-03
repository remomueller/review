class SecretaryRoles < ActiveRecord::Migration
  def self.up
    add_column :users, :pp_committee_secretary, :boolean, :null => false, :default => false
    add_column :users, :steering_committee_secretary, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :pp_committee_secretary
    remove_column :users, :steering_committee_secretary
  end
end

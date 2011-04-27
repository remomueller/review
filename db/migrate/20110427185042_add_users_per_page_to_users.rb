class AddUsersPerPageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :users_per_page, :integer, :null => false, :default => 10
  end

  def self.down
    remove_column :users, :users_per_page
  end
end

class AddUserCommittees < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :pp_committee, :boolean, null: false, default: false
    add_column :users, :steering_committee, :boolean, null: false, default: false
  end
end

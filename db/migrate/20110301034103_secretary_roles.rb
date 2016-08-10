class SecretaryRoles < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :pp_committee_secretary, :boolean, null: false, default: false
    add_column :users, :steering_committee_secretary, :boolean, null: false, default: false
  end
end

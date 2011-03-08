class PublicationTargetedStartDate < ActiveRecord::Migration
  def self.up
    add_column :publications, :targeted_start_date, :date
  end

  def self.down
    remove_column :publications, :targeted_start_date
  end
end

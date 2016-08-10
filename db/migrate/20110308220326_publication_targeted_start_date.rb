class PublicationTargetedStartDate < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :targeted_start_date, :date
  end
end

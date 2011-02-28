class ManuscriptNumber < ActiveRecord::Migration
  def self.up
    add_column :publications, :manuscript_number, :string
  end

  def self.down
    remove_column :publications, :manuscript_number
  end
end

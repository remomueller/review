class ChangeAbbreviatedTitleLimit < ActiveRecord::Migration
  def self.up
    change_column :publications, :abbreviated_title, :string
  end

  def self.down
    change_column :publications, :abbreviated_title, :string, :limit => 40
  end
end

class ChangeAbbreviatedTitleLimit < ActiveRecord::Migration[4.2]
  def up
    change_column :publications, :abbreviated_title, :string
  end

  def down
    change_column :publications, :abbreviated_title, :string, limit: 40
  end
end

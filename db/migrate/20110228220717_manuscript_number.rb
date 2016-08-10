class ManuscriptNumber < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :manuscript_number, :string
  end
end

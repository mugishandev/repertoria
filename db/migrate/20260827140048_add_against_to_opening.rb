class AddAgainstToOpening < ActiveRecord::Migration[8.1]
  def change
    add_column :openings, :against, :string
  end
end

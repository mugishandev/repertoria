class AddColorToOpening < ActiveRecord::Migration[8.1]
  def change
    add_column :openings, :color, :string
  end
end

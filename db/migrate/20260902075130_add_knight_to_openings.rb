class AddKnightToOpenings < ActiveRecord::Migration[8.1]
  def change
    add_column :openings, :logo, :string
  end
end

class AddGendescToOpenings < ActiveRecord::Migration[8.1]
  def change
    add_column :openings, :gendesc, :text
  end
end

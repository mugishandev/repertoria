class AddExplicationsToOpenings < ActiveRecord::Migration[8.1]
  def change
    add_column :openings, :explications, :json
  end
end

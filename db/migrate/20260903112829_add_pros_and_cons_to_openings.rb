class AddProsAndConsToOpenings < ActiveRecord::Migration[8.1]
  def change
    add_column :openings, :pros, :text, array: true, default: [], null: false
    add_column :openings, :cons, :text, array: true, default: [], null: false
  end
end

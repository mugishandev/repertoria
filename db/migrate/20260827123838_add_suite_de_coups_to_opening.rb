class AddSuiteDeCoupsToOpening < ActiveRecord::Migration[8.1]
  def change
    add_column :openings, :suite_de_coups, :string
  end
end

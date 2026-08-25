class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :result
      t.string :user_opening
      t.string :color
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

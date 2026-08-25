class CreateDataAnalyzers < ActiveRecord::Migration[8.1]
  def change
    create_table :data_analyzers do |t|
      t.string :game_stat
      t.references :user, null: false, foreign_key: true
      t.references :opening, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreateOpenings < ActiveRecord::Migration[8.1]
  def change
    create_table :openings do |t|
      t.string :name
      t.text :description
      t.string :video_url
      t.string :image

      t.timestamps
    end
  end
end

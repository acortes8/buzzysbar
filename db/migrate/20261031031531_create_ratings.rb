class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.references :tasting, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.decimal :score, precision: 2, scale: 1, null: false
      t.text :notes

      t.timestamps
    end
    add_index :ratings, [ :tasting_id, :person_id ], unique: true
  end
end

class CreateTastings < ActiveRecord::Migration[8.0]
  def change
    create_table :tastings do |t|
      t.references :occasion, null: false, foreign_key: true
      t.references :drink, null: false, foreign_key: true
      t.text :notes

      t.timestamps
    end
  end
end

class CreateOccasions < ActiveRecord::Migration[8.0]
  def change
    create_table :occasions do |t|
      t.references :place, null: false, foreign_key: true
      t.date :occurred_on, null: false
      t.text :notes

      t.timestamps
    end
  end
end

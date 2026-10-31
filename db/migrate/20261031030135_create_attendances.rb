class CreateAttendances < ActiveRecord::Migration[8.0]
  def change
    create_table :attendances do |t|
      t.references :occasion, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end
    add_index :attendances, [ :occasion_id, :person_id ], unique: true
  end
end

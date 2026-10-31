class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.references :user, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end

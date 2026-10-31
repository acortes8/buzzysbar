class CreateDrinks < ActiveRecord::Migration[8.0]
  def change
    create_table :drinks do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    add_index :drinks, "lower(name)", unique: true
  end
end

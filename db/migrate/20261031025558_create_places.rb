class CreatePlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.string :name, null: false
      t.string :kind, null: false, default: "bar"

      t.timestamps
    end
  end
end

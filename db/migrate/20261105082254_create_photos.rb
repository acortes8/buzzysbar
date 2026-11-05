class CreatePhotos < ActiveRecord::Migration[8.1]
  def change
    create_table :photos do |t|
      t.references :occasion, null: false, foreign_key: true
      t.boolean :published, default: false, null: false

      t.timestamps
    end
  end
end

class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.references :logbook, null: false, foreign_key: true, index: false
      t.string :title, null: false
      t.string :author

      t.timestamps
    end

    add_index :books, "logbook_id, lower((title)::text)", name: "index_books_on_logbook_id_and_lower_title", unique: true
  end
end

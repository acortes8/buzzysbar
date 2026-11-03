# Every user and every logbook record now belongs to a logbook, so the demo
# can't see the family's data. Existing records all go into one "Family"
# logbook.
class CreateLogbooks < ActiveRecord::Migration[8.1]
  TABLES = %i[ users people places drinks occasions ]

  def change
    create_table :logbooks do |t|
      t.string :name, null: false

      t.timestamps
    end

    # Drinks get a unique index on logbook and name below instead.
    TABLES.each { |table| add_reference table, :logbook, foreign_key: true, index: table != :drinks }

    reversible do |direction|
      direction.up do
        if TABLES.any? { |table| select_value("SELECT EXISTS (SELECT 1 FROM #{table})") }
          logbook_id = select_value("INSERT INTO logbooks (name, created_at, updated_at) VALUES ('Family', NOW(), NOW()) RETURNING id")
          TABLES.each { |table| execute "UPDATE #{table} SET logbook_id = #{logbook_id}" }
        end
      end
    end

    TABLES.each { |table| change_column_null table, :logbook_id, false }

    # Drink names are unique within a logbook, not across all of them.
    remove_index :drinks, "lower((name)::text)", name: "index_drinks_on_lower_name", unique: true
    add_index :drinks, "logbook_id, lower((name)::text)", name: "index_drinks_on_logbook_id_and_lower_name", unique: true
  end
end

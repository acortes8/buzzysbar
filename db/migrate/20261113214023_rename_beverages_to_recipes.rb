# A Beverage was really a recipe ("Hurricane" and "Smuggler's Cove Hurricane"
# are two recipes for one drink), so it becomes a Recipe that belongs to a
# Drink, and through it to a logbook. Each existing recipe goes to the drink in
# the family logbook with the same name as its title, created if needed; a
# recipe can be moved to the right drink afterwards. Rich text and the photo
# move with it, and ids stay the same so old /beverages links can redirect.
class RenameBeveragesToRecipes < ActiveRecord::Migration[8.1]
  def up
    rename_table :beverages, :recipes
    add_reference :recipes, :drink, foreign_key: true

    if select_value("SELECT EXISTS (SELECT 1 FROM recipes)")
      logbook_id = select_value("SELECT id FROM logbooks WHERE name <> 'Demo' ORDER BY id LIMIT 1") ||
        select_value("INSERT INTO logbooks (name, created_at, updated_at) VALUES ('Family', NOW(), NOW()) RETURNING id")

      select_rows("SELECT id, title FROM recipes").each do |recipe_id, title|
        name = title.squish
        drink_id = select_value("SELECT id FROM drinks WHERE logbook_id = #{quote(logbook_id)} AND lower(name) = #{quote(name.downcase)}") ||
          select_value("INSERT INTO drinks (logbook_id, name, created_at, updated_at) VALUES (#{quote(logbook_id)}, #{quote(name)}, NOW(), NOW()) RETURNING id")
        execute "UPDATE recipes SET drink_id = #{quote(drink_id)} WHERE id = #{quote(recipe_id)}"
      end
    end

    change_column_null :recipes, :drink_id, false
    change_column_null :recipes, :title, false
    rename_record_type "Beverage", "Recipe"
  end

  def down
    rename_record_type "Recipe", "Beverage"
    change_column_null :recipes, :title, true
    remove_reference :recipes, :drink, foreign_key: true
    rename_table :recipes, :beverages
  end

  private
    def rename_record_type(from, to)
      execute "UPDATE action_text_rich_texts SET record_type = #{quote(to)} WHERE record_type = #{quote(from)}"
      execute "UPDATE active_storage_attachments SET record_type = #{quote(to)} WHERE record_type = #{quote(from)}"
    end
end

class AddBasedOnToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_reference :recipes, :based_on, foreign_key: { to_table: :recipes }
  end
end

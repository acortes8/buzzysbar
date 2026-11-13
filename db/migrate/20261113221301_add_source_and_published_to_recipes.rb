# Where a recipe comes from: our own, a book (and page), or a bartender or bar
# (credit). Existing recipes have no source recorded, and a recipe can only be
# published once its source is known and isn't a book.
class AddSourceAndPublishedToRecipes < ActiveRecord::Migration[8.1]
  def change
    add_column :recipes, :source, :string
    add_reference :recipes, :book, foreign_key: true
    add_column :recipes, :page, :integer
    add_column :recipes, :credit, :string
    add_column :recipes, :published, :boolean, default: false, null: false
  end
end

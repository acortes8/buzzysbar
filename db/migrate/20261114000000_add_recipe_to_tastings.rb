class AddRecipeToTastings < ActiveRecord::Migration[8.1]
  def change
    add_reference :tastings, :recipe, foreign_key: true
  end
end

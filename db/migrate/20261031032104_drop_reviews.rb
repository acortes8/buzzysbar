class DropReviews < ActiveRecord::Migration[8.0]
  # Replaced by tastings and ratings.
  def change
    drop_table :reviews do |t|
      t.string :title
      t.text :body
      t.integer :rating
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

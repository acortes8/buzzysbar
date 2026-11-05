class AddPublishedAndReviewToPlaces < ActiveRecord::Migration[8.1]
  def change
    add_column :places, :published, :boolean, default: false, null: false
    add_column :places, :review, :text
  end
end

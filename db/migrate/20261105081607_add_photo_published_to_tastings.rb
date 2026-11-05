class AddPhotoPublishedToTastings < ActiveRecord::Migration[8.1]
  def change
    add_column :tastings, :photo_published, :boolean, default: false, null: false
  end
end

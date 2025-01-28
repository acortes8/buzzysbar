class CreateBeverages < ActiveRecord::Migration[8.0]
  def change
    create_table :beverages do |t|
      t.string :title

      t.timestamps
    end
  end
end

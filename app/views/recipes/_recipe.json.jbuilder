json.extract! recipe, :id, :title, :drink_id, :created_at, :updated_at
json.url recipe_url(recipe, format: :json)

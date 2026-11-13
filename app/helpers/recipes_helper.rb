module RecipesHelper
  SOURCE_OPTIONS = { "Not recorded" => "", "Our own" => "ours", "A book" => "book", "A bartender" => "bartender", "A bar" => "bar" }

  # Where a recipe comes from, in words: "From Smuggler's Cove, page 112".
  def recipe_source(recipe)
    case recipe.source
    when "ours" then "Our own recipe"
    when "book"
      safe_join([ "From ", link_to(recipe.book.title, recipe.book, class: "underline"), (", page #{recipe.page}" if recipe.page) ])
    when "bartender" then "From #{recipe.credit}"
    when "bar" then "As made at #{recipe.credit}"
    end
  end
end

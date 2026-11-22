require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "input_class marks fields with errors" do
    person = Person.new
    person.validate

    assert_equal [ "input", "text-lg", { "input-error" => true } ], input_class(person, :name, "text-lg")
    assert_equal [ "input", { "input-error" => false } ], input_class(person, :user)
  end

  test "nav_link_to marks the current section" do
    request.path = "/drinks/1"

    assert_dom_equal %(<a aria-current="page" class="nav-link" href="/drinks">Drinks</a>), nav_link_to("Drinks", "/drinks", class: "nav-link")
    assert_dom_equal %(<a href="/recipes">Recipes</a>), nav_link_to("Recipes", "/recipes")
    assert_dom_equal %(<a aria-current="page" href="/">Home</a>), nav_link_to("/", current: true) { "Home" }
  end
end

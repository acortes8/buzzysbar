require "test_helper"

class BeveragesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @beverage = beverages(:mai_tai)
    @title = "The Great Drink #{rand(1000)}"
    login_as users(:one)
  end

  test "should get index" do
    get beverages_url
    assert_response :success
  end

  test "should get new" do
    get new_beverage_url
    assert_response :success
  end

  test "should create beverage" do
    assert_difference("Beverage.count") do
      post beverages_url, params: {
        beverage: {
          title: @title,
          featured_image: file_fixture_upload("test/fixtures/files/mai_tai.jpg", "image/jpeg"),
          ingredient_section: @beverage.ingredient_section.to_s,
          instruction_section: @beverage.instruction_section.to_s,
          description: @beverage.description.to_s
        }
      }
    end

    assert_redirected_to beverage_url(Beverage.last)
  end

  test "should show beverage" do
    get beverage_url(@beverage)
    assert_response :success
  end

  test "should get edit" do
    get edit_beverage_url(@beverage)
    assert_response :success
  end

  test "should update beverage" do
    patch beverage_url(@beverage), params: { beverage: { title: @beverage.title } }
    assert_redirected_to beverage_url(@beverage)
  end

  test "should destroy beverage" do
    assert_difference("Beverage.count", -1) do
      delete beverage_url(@beverage)
    end

    assert_redirected_to beverages_url
  end
end

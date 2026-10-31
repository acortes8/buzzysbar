require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @review = reviews(:one)
    login_as users(:one)
  end

  test "should get index" do
    get reviews_url
    assert_response :success
  end

  test "should show review" do
    get review_url(@review)
    assert_response :success
  end

  test "should get new" do
    get new_review_url
    assert_response :success
  end

  test "should create review for the current user" do
    assert_difference("Review.count") do
      post reviews_url, params: { review: { title: "Great bar", body: "Loved the drinks.", rating: 5 } }
    end

    assert_redirected_to review_url(Review.last)
    assert_equal users(:one), Review.last.user
  end

  test "should not create invalid review" do
    assert_no_difference("Review.count") do
      post reviews_url, params: { review: { title: "", body: "", rating: 6 } }
    end

    assert_response :unprocessable_entity
  end
end

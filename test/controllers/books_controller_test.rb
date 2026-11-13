require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:smugglers_cove)
    login_as users(:one)
  end

  test "should get index" do
    get books_url
    assert_response :success
    assert_select "#books a", text: "Smuggler's Cove"
    assert_select "#books a", text: books(:neighbors_book).title, count: 0
  end

  test "should show book with its recipes" do
    get book_url(@book)
    assert_response :success
    assert_select "#recipes a[href=?]", recipe_path(recipes(:mai_tai_from_book))
  end

  test "should update book" do
    patch book_url(@book), params: { book: { author: "Martin and Rebecca Cate" } }
    assert_redirected_to book_url(@book)
    assert_equal "Martin and Rebecca Cate", @book.reload.author
  end

  test "should not destroy a book with recipes" do
    assert_no_difference("Book.count") do
      delete book_url(@book)
    end
    assert_redirected_to book_url(@book)
  end

  test "should destroy a book without recipes" do
    book = logbooks(:family).books.create!(title: "Unused")
    assert_difference("Book.count", -1) do
      delete book_url(book)
    end
    assert_redirected_to books_url
  end

  test "books are private" do
    delete session_url
    get books_url
    assert_redirected_to new_session_url
  end
end

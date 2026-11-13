require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "requires a title" do
    book = logbooks(:family).books.new(title: " ")
    assert_not book.valid?
    assert_includes book.errors[:title], "can't be blank"
  end

  test "titles are unique per logbook, ignoring case" do
    assert_not logbooks(:family).books.new(title: "smuggler's  cove").valid?
    assert logbooks(:neighbors).books.new(title: "Smuggler's Cove").valid?
  end

  test "find_or_initialize_by_title finds or builds a book in the logbook" do
    assert_equal books(:smugglers_cove), logbooks(:family).books.find_or_initialize_by_title(" SMUGGLER'S cove ")

    book = logbooks(:family).books.find_or_initialize_by_title("Tiki: Modern Tropical Cocktails")
    assert book.new_record?
    assert_equal logbooks(:family), book.logbook
  end

  test "can't be deleted while it has recipes" do
    book = books(:smugglers_cove)
    assert_not book.destroy
    assert_includes book.errors[:base], "Can't be deleted while it has recipes"
  end
end

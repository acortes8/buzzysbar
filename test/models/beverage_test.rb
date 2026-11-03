require "test_helper"

class BeverageTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  test "beverage attributes must not be empty" do
    beverage = Beverage.new
    assert beverage.invalid?
    assert beverage.errors[:title].any?
    assert beverage.errors[:featured_image].any?
    assert beverage.errors[:ingredient_section].any?
    assert beverage.errors[:instruction_section].any?
    assert beverage.errors[:description].any?
  end

  test "beverage is not valid without a unique title" do
    beverage = Beverage.new(title:  beverages(:mai_tai).title)
    assert beverage.invalid?
    assert_equal [ I18n.translate("errors.messages.taken") ], beverage.errors[:title]
  end

  test "accepts a HEIC featured image" do
    beverage = beverages(:mai_tai)
    beverage.featured_image.attach(fixture_file_upload("drink.heic", "image/heic"))
    beverage.valid?
    assert_empty beverage.errors[:featured_image]
  end

  test "rejects a featured image that isn't an image" do
    beverage = beverages(:mai_tai)
    beverage.featured_image.attach(fixture_file_upload("notes.txt", "text/plain"))
    assert_not beverage.valid?
    assert_includes beverage.errors[:featured_image], "must be a JPEG, PNG, GIF, WebP, or HEIC image"
  end
end

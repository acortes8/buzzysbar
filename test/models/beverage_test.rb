require "test_helper"

class BeverageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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
end

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
end

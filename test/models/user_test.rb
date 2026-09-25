require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "社員番号と氏名があれば有効" do
    user = User.new(employee_number: "2001", name: "新規社員", password: "password")

    assert user.valid?
  end

  test "社員番号がない場合は無効" do
    user = User.new(employee_number: "", name: "新規社員", password: "password")

    assert_not user.valid?
  end

  test "社員番号が重複している場合は無効" do
    user = User.new(employee_number: @user.employee_number, name: "重複社員", password: "password")

    assert_not user.valid?
  end

  test "氏名がない場合は無効" do
    user = User.new(employee_number: "2001", name: "", password: "password")

    assert_not user.valid?
  end

  test "権限を指定しない場合は一般社員になる" do
    user = User.new(employee_number: "2001", name: "新規社員", password: "password")

    assert user.employee?
  end
end

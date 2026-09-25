require "test_helper"

class AlcoholCheckTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @checker = users(:two)
  end

  test "正しいデータなら登録できる" do
    alcohol_check = AlcoholCheck.new(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true
    )

    assert alcohol_check.valid?
  end

  test "アルコール濃度がない場合は登録できない" do
    alcohol_check = AlcoholCheck.new(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: nil,
      used_detector: true
    )

    assert_not alcohol_check.valid?
    assert alcohol_check.errors[:alcohol_value].present?
  end

  test "本人を確認者にはできない" do
    alcohol_check = AlcoholCheck.new(
      user: @user,
      checker: @user,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true
    )

    assert_not alcohol_check.valid?
    assert alcohol_check.errors[:checker].present?
  end

  test "同じ日に同じ種類のチェックは2回登録できない" do
    AlcoholCheck.create!(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true
    )

    second_check = AlcoholCheck.new(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true
    )

    assert_not second_check.valid?
    assert second_check.errors[:base].present?
  end

  test "同じ日でも出社時と帰社時はそれぞれ登録できる" do
    AlcoholCheck.create!(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true
    )

    departure_check = AlcoholCheck.new(
      user: @user,
      checker: @checker,
      check_type: :departure,
      alcohol_value: 0.00,
      used_detector: true
    )

    assert departure_check.valid?
  end

  test "当日に登録済みでも過去日付の同種チェックは登録できる" do
    AlcoholCheck.create!(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true
    )

    past_check = AlcoholCheck.new(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true,
      checked_on: Date.current.yesterday
    )

    assert past_check.valid?
  end

  test "過去日付でも同じ日に同じ種類のチェックは2回登録できない" do
    AlcoholCheck.create!(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true,
      checked_on: Date.current.yesterday
    )

    duplicate_check = AlcoholCheck.new(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true,
      checked_on: Date.current.yesterday
    )

    assert_not duplicate_check.valid?
    assert duplicate_check.errors[:base].present?
  end

  test "DBレベルでも同日同種の重複登録を防止する" do
    AlcoholCheck.create!(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true,
      checked_on: Date.current
    )

    duplicate_check = AlcoholCheck.new(
      user: @user,
      checker: @checker,
      check_type: :arrival,
      alcohol_value: 0.00,
      used_detector: true,
      checked_on: Date.current
    )

    assert_raises ActiveRecord::RecordNotUnique do
      duplicate_check.save!(validate: false)
    end
  end
end

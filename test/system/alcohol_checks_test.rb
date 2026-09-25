require "application_system_test_case"

class AlcoholChecksSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
    @checker = users(:two)
  end

  test "社員番号とパスワードでログインし、出社時チェックを登録できる" do
    @user.update!(password: "password123")

    visit root_path

    fill_in "社員番号", with: @user.employee_number
    fill_in "パスワード", with: "password123"
    click_on "ログイン"

    within arrival_card do
      fill_in "アルコール濃度", with: "0.00"
      select @checker.name, from: "確認者"
      check "検知器を使用した"
      click_on "出社時チェックを登録"
    end

    assert_text "アルコールチェックを登録しました"
    within(arrival_card) { assert_text "チェック済みです" }
  end

  test "確認者を選ばずに登録するとエラーが表示され、登録されない" do
    sign_in @user
    visit root_path

    within arrival_card do
      fill_in "アルコール濃度", with: "0.00"
      click_on "出社時チェックを登録"
    end

    assert_text "出社時のアルコールチェックに失敗しました"
    assert_equal 0, @user.alcohol_checks.count
  end

  private

  def arrival_card
    find("h2", text: "出社時チェック").find(:xpath, "..")
  end
end

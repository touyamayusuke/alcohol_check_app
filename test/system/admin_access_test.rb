require "application_system_test_case"

class AdminAccessSystemTest < ApplicationSystemTestCase
  test "管理者は画面のリンクから管理画面を開ける" do
    sign_in users(:admin)
    visit root_path

    click_on "チェック状況一覧"

    assert_text "本日のアルコールチェック状況"
  end

  test "一般社員には管理画面へのリンクが表示されず、URLを直接開いても入れない" do
    sign_in users(:one)
    visit root_path

    assert_no_link "チェック状況一覧"

    visit admin_root_path

    assert_text "管理者権限が必要です"
    assert_no_text "本日のアルコールチェック状況"
  end
end

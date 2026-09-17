require "test_helper"

class AlcoholChecksTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @checker = users(:two)

    sign_in @user
  end

  test "ログインユーザーがアルコールチェックを登録できる" do
    assert_difference "AlcoholCheck.count", 1 do
      post alcohol_checks_path, params: {
        alcohol_check: {
          check_type: "arrival",
          alcohol_value: 0.00,
          checker_id: @checker.id,
          used_detector: "1"
        }
      }
    end

    assert_redirected_to root_path
  end

  test "未ログインユーザーはアルコールチェックを登録できない" do
    sign_out @user

    assert_no_difference "AlcoholCheck.count" do
      post alcohol_checks_path, params: {
        alcohol_check: {
          check_type: "arrival",
          alcohol_value: 0.00,
          checker_id: @checker.id,
          used_detector: "1"
        }
      }
      end

      assert_redirected_to new_user_session_path
    end
end

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

  test "同じ日に同じ種類のチェックを2回登録するとエラーになる" do
    AlcoholCheck.create!(user: @user, checker: @checker, check_type: :arrival, alcohol_value: 0.00)

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

    assert_response :unprocessable_entity
    assert_includes flash[:alert], "同じ種類のアルコールチェックは1日1回までです"
  end

  test "同時リクエストでDB制約に弾かれた場合も500にならずエラー表示される" do
    AlcoholCheck.create!(user: @user, checker: @checker, check_type: :arrival, alcohol_value: 0.00)

    # 同時リクエストで両方がバリデーションを通過した状況を再現する
    AlcoholCheck.skip_callback(:validate, :only_one_check_per_type_per_day)

    begin
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
    ensure
      AlcoholCheck.validate :only_one_check_per_type_per_day, on: :create
    end

    assert_response :unprocessable_entity
    assert_includes flash[:alert], "同じ種類のアルコールチェックは1日1回までです"
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

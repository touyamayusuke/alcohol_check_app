require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @employee = users(:one)

    @original_initial_user_password = ENV["INITIAL_USER_PASSWORD"]
    ENV["INITIAL_USER_PASSWORD"] = "initial-password"
  end

  teardown do
    ENV["INITIAL_USER_PASSWORD"] = @original_initial_user_password
  end

  test "管理者はユーザー一覧を表示できる" do
    sign_in @admin

    get admin_users_path

    assert_response :success
  end

  test "一般社員はユーザー一覧にアクセスできない" do
    sign_in @employee

    get admin_users_path

    assert_redirected_to root_path
  end

  test "未ログインユーザーはユーザー一覧にアクセスできない" do
    get admin_users_path

    assert_redirected_to new_user_session_path
  end

  test "管理者はユーザー登録画面を表示できる" do
    sign_in @admin

    get new_admin_user_path

    assert_response :success
  end

  test "管理者はユーザーを登録できる" do
    sign_in @admin

    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: { employee_number: "2001", name: "新規社員", role: "employee" }
      }
    end

    assert_redirected_to admin_users_path
  end

  test "登録したユーザーには初期パスワードが設定される" do
    sign_in @admin

    post admin_users_path, params: {
      user: { employee_number: "2001", name: "新規社員", role: "employee" }
    }

    user = User.find_by!(employee_number: "2001")
    assert user.valid_password?("initial-password")
  end

  test "社員番号が重複している場合はユーザーを登録できない" do
    sign_in @admin

    assert_no_difference("User.count") do
      post admin_users_path, params: {
        user: { employee_number: @employee.employee_number, name: "重複社員", role: "employee" }
      }
    end

    assert_response :unprocessable_entity
  end

  test "一般社員はユーザーを登録できない" do
    sign_in @employee

    assert_no_difference("User.count") do
      post admin_users_path, params: {
        user: { employee_number: "2001", name: "新規社員", role: "admin" }
      }
    end

    assert_redirected_to root_path
  end

  test "管理者はユーザー編集画面を表示できる" do
    sign_in @admin

    get edit_admin_user_path(@employee)

    assert_response :success
  end

  test "管理者はユーザーの権限を変更できる" do
    sign_in @admin

    patch admin_user_path(@employee), params: { user: { role: "admin" } }

    assert_redirected_to admin_users_path
    assert @employee.reload.admin?
  end

  test "氏名が空の場合はユーザー情報を更新できない" do
    sign_in @admin

    patch admin_user_path(@employee), params: { user: { name: "" } }

    assert_response :unprocessable_entity
    assert_equal "テスト社員1", @employee.reload.name
  end

  test "一般社員は自分の権限を管理者に変更できない" do
    sign_in @employee

    patch admin_user_path(@employee), params: { user: { role: "admin" } }

    assert_redirected_to root_path
    assert @employee.reload.employee?
  end
end

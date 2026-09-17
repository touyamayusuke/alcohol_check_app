require "test_helper"

class AdminAccessTest < ActionDispatch::IntegrationTest
  test "一般社員は管理画面にアクセスできない" do
    user = users(:one)

    sign_in user

    get admin_root_path

    assert_redirected_to root_path
  end

  test "管理者は管理画面にアクセスできる" do
    admin = users(:admin)

    sign_in admin

    get admin_root_path

    assert_response :success
  end
end

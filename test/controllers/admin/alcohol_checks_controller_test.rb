require "test_helper"

class Admin::AlcoholChecksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_alcohol_checks_index_url
    assert_response :success
  end
end

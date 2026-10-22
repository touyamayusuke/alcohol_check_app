require "test_helper"

class Admin::AlcoholChecksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @employee = users(:one)
  end

  test "管理者はCSVをBOM付きUTF-8でダウンロードできる" do
    sign_in @admin

    get admin_alcohol_checks_path(format: :csv)

    assert_response :success
    body = response.body.dup.force_encoding(Encoding::UTF_8)
    assert body.start_with?("﻿")
    assert_includes body.lines.first, "社員番号"
  end

  test "一般社員はCSVをダウンロードできない" do
    sign_in @employee

    get admin_alcohol_checks_path(format: :csv)

    assert_redirected_to root_path
  end
end

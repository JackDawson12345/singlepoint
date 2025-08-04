require "test_helper"

class Admin::ThemesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_themes_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_themes_show_url
    assert_response :success
  end

  test "should get edit" do
    get admin_themes_edit_url
    assert_response :success
  end

  test "should get new" do
    get admin_themes_new_url
    assert_response :success
  end
end

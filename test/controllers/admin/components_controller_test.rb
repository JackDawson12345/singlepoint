require "test_helper"

class Admin::ComponentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_components_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_components_show_url
    assert_response :success
  end

  test "should get edit" do
    get admin_components_edit_url
    assert_response :success
  end

  test "should get new" do
    get admin_components_new_url
    assert_response :success
  end
end

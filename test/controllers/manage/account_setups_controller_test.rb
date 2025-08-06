require "test_helper"

class Manage::AccountSetupsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get manage_account_setups_show_url
    assert_response :success
  end
end

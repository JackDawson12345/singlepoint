require "test_helper"

class Manage::ServicesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_services_index_url
    assert_response :success
  end
end

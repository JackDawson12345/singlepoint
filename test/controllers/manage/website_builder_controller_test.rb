require "test_helper"

class Manage::WebsiteBuilderControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get manage_website_builder_index_url
    assert_response :success
  end
end

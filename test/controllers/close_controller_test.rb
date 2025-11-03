require "test_helper"

class CloseControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get close_create_url
    assert_response :success
  end
end

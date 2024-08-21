require "test_helper"

class CommercialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @commercial = commercials(:one)
  end

  test "should get index" do
    get commercials_url
    assert_response :success
  end

  test "should get new" do
    get new_commercial_url
    assert_response :success
  end

  test "should create commercial" do
    assert_difference('Commercial.count') do
      post commercials_url, params: { commercial: { file_path: @commercial.file_path, title: @commercial.title } }
    end

    assert_redirected_to commercial_url(Commercial.last)
  end

  test "should show commercial" do
    get commercial_url(@commercial)
    assert_response :success
  end

  test "should get edit" do
    get edit_commercial_url(@commercial)
    assert_response :success
  end

  test "should update commercial" do
    patch commercial_url(@commercial), params: { commercial: { file_path: @commercial.file_path, title: @commercial.title } }
    assert_redirected_to commercial_url(@commercial)
  end

  test "should destroy commercial" do
    assert_difference('Commercial.count', -1) do
      delete commercial_url(@commercial)
    end

    assert_redirected_to commercials_url
  end
end

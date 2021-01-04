require "test_helper"

class AiringsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @airing = airings(:one)
  end

  test "should get index" do
    get airings_url
    assert_response :success
  end

  test "should get new" do
    get new_airing_url
    assert_response :success
  end

  test "should create airing" do
    assert_difference('Airing.count') do
      post airings_url, params: { airing: { channel_id: @airing.channel_id, recurrence: @airing.recurrence, show_id: @airing.show_id } }
    end

    assert_redirected_to airing_url(Airing.last)
  end

  test "should show airing" do
    get airing_url(@airing)
    assert_response :success
  end

  test "should get edit" do
    get edit_airing_url(@airing)
    assert_response :success
  end

  test "should update airing" do
    patch airing_url(@airing), params: { airing: { channel_id: @airing.channel_id, recurrence: @airing.recurrence, show_id: @airing.show_id } }
    assert_redirected_to airing_url(@airing)
  end

  test "should destroy airing" do
    assert_difference('Airing.count', -1) do
      delete airing_url(@airing)
    end

    assert_redirected_to airings_url
  end
end

require "test_helper"

class MonitoredUrlsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @monitored_url = monitored_urls(:one)
  end

  test "should get index" do
    get monitored_urls_url
    assert_response :success
  end

  test "should get new" do
    get new_monitored_url_url
    assert_response :success
  end

  test "should create monitored_url" do
    assert_difference("MonitoredUrl.count") do
      post monitored_urls_url, params: { monitored_url: { active: @monitored_url.active, name: @monitored_url.name, url: @monitored_url.url } }
    end

    assert_redirected_to monitored_url_url(MonitoredUrl.last)
  end

  test "should show monitored_url" do
    get monitored_url_url(@monitored_url)
    assert_response :success
  end

  test "should get edit" do
    get edit_monitored_url_url(@monitored_url)
    assert_response :success
  end

  test "should update monitored_url" do
    patch monitored_url_url(@monitored_url), params: { monitored_url: { active: @monitored_url.active, name: @monitored_url.name, url: @monitored_url.url } }
    assert_redirected_to monitored_url_url(@monitored_url)
  end

  test "should destroy monitored_url" do
    assert_difference("MonitoredUrl.count", -1) do
      delete monitored_url_url(@monitored_url)
    end

    assert_redirected_to monitored_urls_url
  end
end

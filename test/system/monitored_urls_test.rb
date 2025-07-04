require "application_system_test_case"

class MonitoredUrlsTest < ApplicationSystemTestCase
  setup do
    @monitored_url = monitored_urls(:one)
  end

  test "visiting the index" do
    visit monitored_urls_url
    assert_selector "h1", text: "Monitored urls"
  end

  test "should create monitored url" do
    visit monitored_urls_url
    click_on "New monitored url"

    check "Active" if @monitored_url.active
    fill_in "Name", with: @monitored_url.name
    fill_in "Url", with: @monitored_url.url
    click_on "Create Monitored url"

    assert_text "Monitored url was successfully created"
    click_on "Back"
  end

  test "should update Monitored url" do
    visit monitored_url_url(@monitored_url)
    click_on "Edit this monitored url", match: :first

    check "Active" if @monitored_url.active
    fill_in "Name", with: @monitored_url.name
    fill_in "Url", with: @monitored_url.url
    click_on "Update Monitored url"

    assert_text "Monitored url was successfully updated"
    click_on "Back"
  end

  test "should destroy Monitored url" do
    visit monitored_url_url(@monitored_url)
    accept_confirm { click_on "Destroy this monitored url", match: :first }

    assert_text "Monitored url was successfully destroyed"
  end
end

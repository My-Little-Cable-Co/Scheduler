require "application_system_test_case"

class CommercialsTest < ApplicationSystemTestCase
  setup do
    @commercial = commercials(:one)
  end

  test "visiting the index" do
    visit commercials_url
    assert_selector "h1", text: "Commercials"
  end

  test "creating a Commercial" do
    visit commercials_url
    click_on "New Commercial"

    fill_in "File path", with: @commercial.file_path
    fill_in "Title", with: @commercial.title
    click_on "Create Commercial"

    assert_text "Commercial was successfully created"
    click_on "Back"
  end

  test "updating a Commercial" do
    visit commercials_url
    click_on "Edit", match: :first

    fill_in "File path", with: @commercial.file_path
    fill_in "Title", with: @commercial.title
    click_on "Update Commercial"

    assert_text "Commercial was successfully updated"
    click_on "Back"
  end

  test "destroying a Commercial" do
    visit commercials_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Commercial was successfully destroyed"
  end
end

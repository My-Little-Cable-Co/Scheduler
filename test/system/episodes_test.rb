require "application_system_test_case"

class EpisodesTest < ApplicationSystemTestCase
  setup do
    @episode = episodes(:one)
  end

  test "visiting the index" do
    visit episodes_url
    assert_selector "h1", text: "Episodes"
  end

  test "creating a Episode" do
    visit episodes_url
    click_on "New Episode"

    fill_in "Filepath", with: @episode.filepath
    fill_in "Name", with: @episode.name
    fill_in "Number", with: @episode.number
    fill_in "Season", with: @episode.season_id
    fill_in "Show", with: @episode.show_id
    click_on "Create Episode"

    assert_text "Episode was successfully created"
    click_on "Back"
  end

  test "updating a Episode" do
    visit episodes_url
    click_on "Edit", match: :first

    fill_in "Filepath", with: @episode.filepath
    fill_in "Name", with: @episode.name
    fill_in "Number", with: @episode.number
    fill_in "Season", with: @episode.season_id
    fill_in "Show", with: @episode.show_id
    click_on "Update Episode"

    assert_text "Episode was successfully updated"
    click_on "Back"
  end

  test "destroying a Episode" do
    visit episodes_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Episode was successfully destroyed"
  end
end

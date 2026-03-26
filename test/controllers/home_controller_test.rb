require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'renders the main workspace shell' do
    get root_url

    assert_response :success
    assert_select "[data-controller='shell']"
    assert_select '.app-sidebar', text: /WMS Pro/
    assert_select '.workspace-tab'
    assert_select 'a.sidebar-menu__button', text: /SearchForm/
    assert_select '.topbar__search input[placeholder]'
  end
end
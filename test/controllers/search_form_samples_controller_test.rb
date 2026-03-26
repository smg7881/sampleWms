require 'test_helper'

class SearchFormSamplesControllerTest < ActionDispatch::IntegrationTest
  test 'renders the search form sample screen' do
    get search_form_sample_url

    assert_response :success
    assert_select '.client-search-page-header h1', text: /SearchForm/
    assert_select "[data-controller='search-form']"
    assert_select "input[name='q[client_code]']"
    assert_select "select[name='q[client_group]']"
    assert_select "input[name='q[registered_on]'][type='date']"
    assert_select 'tbody tr', count: 6
  end

  test 'restores filters and narrows results' do
    get search_form_sample_url, params: { q: { client_name: 'rqre', client_group: 'Customer', active: 'Y', registered_on: '2026-03-02' } }

    assert_response :success
    assert_select "input[name='q[client_name]'][value='rqre']"
    assert_select "option[value='Customer'][selected]"
    assert_select "option[value='Y'][selected]"
    assert_select "input[name='q[registered_on]'][value='2026-03-02']"
    assert_select 'tbody tr', count: 1
    assert_select 'tbody tr td', text: /00000001/
  end
end
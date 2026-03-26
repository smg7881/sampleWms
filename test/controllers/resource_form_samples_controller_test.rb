require 'test_helper'

class ResourceFormSamplesControllerTest < ActionDispatch::IntegrationTest
  test 'renders the resource form sample screen' do
    get resource_form_sample_url

    assert_response :success
    assert_select '.resource-form-sample__panel-header h1', text: /ResourceForm/
    assert_select "[data-controller~='resource-form']"
    assert_select "input[name='client[client_code]'][value='00000001']"
    assert_select "input[name='client[corporation_code]'][value='23423']"
    assert_select "select[name='client[client_group]']"
    assert_select "input[name='client[effective_from]'][type='date'][value='2026-02-26']"
  end

  test 're-renders submitted values on update' do
    patch resource_form_sample_url, params: {
      client: {
        client_code: 'CLX009',
        client_name: 'Global Parts',
        corporation_name: 'HQ West',
        corporation_code: 'HQW1',
        business_number: '5551112222',
        client_group: 'Supplier',
        client_type: 'Domestic Supplier',
        country_code: 'KR',
        effective_from: '2026-03-10',
        active: 'Y'
      }
    }

    assert_response :success
    assert_select "input[name='client[client_code]'][value='CLX009']"
    assert_select "input[name='client[client_name]'][value='Global Parts']"
    assert_select "input[name='client[corporation_code]'][value='HQW1']"
    assert_select "option[value='Supplier'][selected]"
  end
end

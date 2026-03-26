class ResourceFormSamplesController < ApplicationController
  SAMPLE_CLIENTS = [
    {
      client_code: '00000001',
      client_name: 'rqre4533',
      corporation_name: '관리법인 선택',
      corporation_code: '23423',
      business_number: '2344233243',
      client_group: 'Customer',
      client_type: 'Domestic Customer',
      client_category: 'Corporate',
      country_code: 'US',
      parent_client_name: '상위거래처 선택',
      parent_client_code: '',
      representative_name: '234',
      representative_business_number: '234234',
      postal_address_name: '우편번호 선택',
      postal_code: '234',
      address_line1: '2342',
      address_line2: '234234',
      effective_from: '2026-02-26',
      effective_to: '2026-02-26',
      active: 'Y'
    },
    {
      client_code: 'CLX001',
      client_name: 'X',
      corporation_name: '관리법인 선택',
      corporation_code: '23423',
      business_number: '1234567890',
      client_group: 'Customer',
      client_type: 'Domestic Customer',
      client_category: 'Corporate',
      country_code: 'KR',
      parent_client_name: '',
      parent_client_code: '',
      representative_name: 'EMP01',
      representative_business_number: 'CORP01',
      postal_address_name: '우편번호 선택',
      postal_code: '',
      address_line1: '',
      address_line2: '',
      effective_from: '2026-02-26',
      effective_to: '2026-02-26',
      active: 'Y'
    }
  ].freeze

  def show
    @model = SampleClientProfile.new(SAMPLE_CLIENTS.first)
    @clients = SAMPLE_CLIENTS
  end

  def update
    @model = SampleClientProfile.new(resource_params)
    @clients = SAMPLE_CLIENTS
    @model.validate
    render :show, status: (@model.errors.any? ? :unprocessable_entity : :ok)
  end

  private

  def resource_params
    params.fetch(:client, {}).permit(
      :client_code, :client_name, :corporation_name, :corporation_code, :business_number,
      :client_group, :client_type, :client_category, :country_code, :parent_client_name,
      :parent_client_code, :representative_name, :representative_business_number,
      :postal_address_name, :postal_code, :address_line1, :address_line2,
      :effective_from, :effective_to, :active
    )
  end
end

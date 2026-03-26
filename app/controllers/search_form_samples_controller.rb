class SearchFormSamplesController < ApplicationController
  SAMPLE_CLIENTS = [
    { client_code: '00000001', client_name: 'rqre4533', corporation_name: '23423', client_group: 'Customer', client_type: 'Domestic Customer', business_number: '2344233243', active: 'Y', country: 'US', manager: 'admin01', registered_on: '2026-03-02', modified_at: '2026-03-02 13:07' },
    { client_code: 'CLX001', client_name: 'X', corporation_name: 'CORP01', client_group: 'Customer', client_type: 'Domestic Customer', business_number: '1234567890', active: 'Y', country: 'KR', manager: 'system', registered_on: '2026-03-02', modified_at: '2026-03-02 13:17' },
    { client_code: 'APX201', client_name: 'Alpha Chemicals', corporation_name: 'HQ01', client_group: 'Supplier', client_type: 'Overseas Supplier', business_number: '2233445566', active: 'N', country: 'CN', manager: 'minji', registered_on: '2026-03-04', modified_at: '2026-03-04 09:20' },
    { client_code: 'B2B900', client_name: 'Best Trade Partner', corporation_name: 'HQ02', client_group: 'Partner', client_type: 'Domestic Vendor', business_number: '9988776655', active: 'Y', country: 'JP', manager: 'admin02', registered_on: '2026-03-05', modified_at: '2026-03-05 16:41' },
    { client_code: 'DSK777', client_name: 'DSK Foods', corporation_name: 'CORP01', client_group: 'Customer', client_type: 'Domestic Customer', business_number: '5522117788', active: 'Y', country: 'KR', manager: 'admin03', registered_on: '2026-03-06', modified_at: '2026-03-06 11:12' },
    { client_code: 'NOVA88', client_name: 'Nova Parts', corporation_name: 'HQ03', client_group: 'Supplier', client_type: 'Overseas Supplier', business_number: '3344556677', active: 'N', country: 'US', manager: 'system', registered_on: '2026-03-08', modified_at: '2026-03-08 14:55' }
  ].freeze

  def show
    @filters = search_params.to_h
    @clients = filtered_clients
  end

  private

  def search_params
    params.fetch(:q, {}).permit(
      :client_code,
      :client_name,
      :corporation_name,
      :client_group,
      :client_type,
      :business_number,
      :active,
      :registered_on
    )
  end

  def filtered_clients
    clients = SAMPLE_CLIENTS.dup
    filters = search_params.to_h

    %w[client_code client_name corporation_name business_number].each do |key|
      next if filters[key].blank?

      query = filters[key].downcase
      clients.select! { |client| client[key.to_sym].to_s.downcase.include?(query) }
    end

    %w[client_group client_type active registered_on].each do |key|
      next if filters[key].blank?

      clients.select! { |client| client[key.to_sym].to_s == filters[key] }
    end

    clients.sort_by { |client| [client[:client_code], client[:client_name]] }
  end
end
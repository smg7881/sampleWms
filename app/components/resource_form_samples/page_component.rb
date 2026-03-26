module ResourceFormSamples
  class PageComponent < ApplicationComponent
    def initialize(model:, clients:)
      @model = model
      @clients = clients
    end

    private

    attr_reader :model, :clients

    def form_fields
      [
        { field: 'client_code', type: 'input', label: '거래처코드', required: true, span: '24 s:12 m:8' },
        { field: 'client_name', type: 'input', label: '거래처명', required: true, span: '24 s:12 m:8' },
        {
          field: 'corporation_name', type: 'popup', label: '관리법인', required: true, span: '24 s:12 m:8',
          popup_type: 'corporation', code_field: 'corporation_code', code_width: '8.5rem', button_width: '2.75rem',
          options: [
            { value: '23423', display: 'Global HQ', meta: 'North America' },
            { value: 'HQ01', display: 'SMG Korea', meta: 'Seoul' },
            { value: 'HQ02', display: 'SMG Japan', meta: 'Tokyo' }
          ]
        },
        { field: 'business_number', type: 'input', label: '사업자번호', required: true, span: '24 s:12 m:8' },
        { field: 'client_group', type: 'select', label: '거래처구분그룹', required: true, span: '24 s:12 m:8', options: [['Customer', 'Customer'], ['Supplier', 'Supplier'], ['Partner', 'Partner']] },
        { field: 'client_type', type: 'select', label: '거래처구분', required: true, span: '24 s:12 m:8', options: [['Domestic Customer', 'Domestic Customer'], ['Domestic Supplier', 'Domestic Supplier'], ['Overseas Customer', 'Overseas Customer']] },
        { field: 'client_category', type: 'select', label: '거래처종류', span: '24 s:12 m:8', options: [['Corporate', 'Corporate'], ['Individual', 'Individual']] },
        { field: 'country_code', type: 'select', label: '국가', required: true, span: '24 s:12 m:8', options: [['United States', 'US'], ['Korea', 'KR'], ['Japan', 'JP']] },
        {
          field: 'parent_client_name', type: 'popup', label: '상위거래처', span: '24 s:12 m:8',
          popup_type: 'client', code_field: 'parent_client_code', code_width: '8.5rem', button_width: '2.75rem',
          options: [
            { value: 'PAR001', display: 'Corporate Holdings', meta: 'Customer Group' },
            { value: 'PAR002', display: 'Blue Harbor Logistics', meta: 'Partner' },
            { value: 'PAR003', display: 'East Trade Alliance', meta: 'Supplier Hub' }
          ]
        },
        { field: 'representative_name', type: 'input', label: '대표거래처', span: '24 s:12 m:8' },
        { field: 'representative_business_number', type: 'input', label: '대표영업사원명', span: '24 s:12 m:8' },
        {
          field: 'postal_address_name', type: 'popup', label: '우편번호', span: '24 s:8 m:8',
          popup_type: 'zipcode', code_field: 'postal_code', code_width: '7rem', button_width: '2.75rem',
          options: [
            { value: '04524', display: '서울 중구 세종대로 110', meta: '서울특별시' },
            { value: '06134', display: '서울 강남구 테헤란로 152', meta: '강남구' },
            { value: '07328', display: '서울 영등포구 국제금융로 10', meta: '여의도' }
          ]
        },
        { field: 'address_line1', type: 'input', label: '주소', span: '24 s:16 m:12' },
        { field: 'address_line2', type: 'input', label: '상세주소', span: '24 s:24 m:12' },
        { field: 'effective_from', type: 'date_picker', label: '적용시작일', required: true, span: '24 s:12 m:8' },
        { field: 'effective_to', type: 'date_picker', label: '적용종료일', span: '24 s:12 m:8' },
        { field: 'active', type: 'select', label: '사용여부', required: true, span: '24 s:12 m:8', options: [['사용', 'Y'], ['미사용', 'N']] }
      ]
    end

    def tabs
      ['거래처기본정보', '거래처추가정보', '거래처담당자', '거래처작업장']
    end

    def active_client
      clients.first
    end
  end
end

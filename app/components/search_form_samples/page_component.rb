module SearchFormSamples
  class PageComponent < ApplicationComponent
    def initialize(filters:, clients:)
      @filters = filters.to_h
      @clients = clients
    end

    private

    attr_reader :filters, :clients

    def sample_fields
      [
        { field: 'client_code', type: 'input', label: "\uac70\ub798\ucc98\ucf54\ub4dc", placeholder: "\uac70\ub798\ucc98 \ucf54\ub4dc \uac80\uc0c9", span: '24 s:12 m:6', control_max_width: '100%' },
        { field: 'client_name', type: 'input', label: "\uac70\ub798\ucc98\uba85", placeholder: "\uac70\ub798\ucc98\uba85 \uac80\uc0c9", span: '24 s:12 m:6', control_max_width: '100%' },
        { field: 'corporation_name', type: 'input', label: "\uad00\ub9ac\ubc95\uc778", placeholder: "\uad00\ub9ac\ubc95\uc778 \uc120\ud0dd", span: '24 s:12 m:6', control_max_width: '100%', action_button: { icon: 'search', aria_label: "\uad00\ub9ac\ubc95\uc778 \uc870\ud68c" } },
        { field: 'client_group', type: 'select', label: "\uac70\ub798\ucc98\uad6c\ubd84\uadf8\ub8f9", placeholder: "\uc804\uccb4", span: '24 s:12 m:6', control_max_width: '100%', options: [['Customer', 'Customer'], ['Supplier', 'Supplier'], ['Partner', 'Partner']] },
        { field: 'client_type', type: 'select', label: "\uac70\ub798\ucc98\uad6c\ubd84", placeholder: "\uc804\uccb4", span: '24 s:12 m:6', control_max_width: '100%', options: [['Domestic Customer', 'Domestic Customer'], ['Domestic Vendor', 'Domestic Vendor'], ['Overseas Customer', 'Overseas Customer'], ['Overseas Supplier', 'Overseas Supplier']] },
        { field: 'business_number', type: 'input', label: "\uc0ac\uc5c5\uc790\ubc88\ud638", placeholder: "\uc22b\uc790 10\uc790\ub9ac", span: '24 s:12 m:6', control_max_width: '100%' },
        { field: 'active', type: 'select', label: "\uc0ac\uc6a9\uc5ec\ubd80", placeholder: "\uc804\uccb4", span: '24 s:12 m:6', control_max_width: '100%', options: [["\uc0ac\uc6a9", 'Y'], ["\ubbf8\uc0ac\uc6a9", 'N']] },
        { field: 'registered_on', type: 'date_picker', label: "\ub4f1\ub85d\uc77c", span: '24 s:12 m:6', control_width: '100%', control_max_width: '100%' }
      ]
    end

    def selected_client
      clients.first
    end

    def summary_cards
      [
        { label: "\uc804\uccb4 \uac70\ub798\ucc98", value: clients.count },
        { label: "\uc0ac\uc6a9 \uac70\ub798\ucc98", value: clients.count { |client| client[:active] == 'Y' } },
        { label: "\ud574\uc678 \uac70\ub798\ucc98", value: clients.count { |client| client[:country] != 'KR' } }
      ]
    end

    def active_filter_tags
      {
        "\uac70\ub798\ucc98\ucf54\ub4dc" => filters['client_code'],
        "\uac70\ub798\ucc98\uba85" => filters['client_name'],
        "\uad00\ub9ac\ubc95\uc778" => filters['corporation_name'],
        "\uac70\ub798\ucc98\uad6c\ubd84\uadf8\ub8f9" => filters['client_group'],
        "\uac70\ub798\ucc98\uad6c\ubd84" => filters['client_type'],
        "\uc0ac\uc5c5\uc790\ubc88\ud638" => filters['business_number'],
        "\uc0ac\uc6a9\uc5ec\ubd80" => active_label(filters['active']),
        "\ub4f1\ub85d\uc77c" => filters['registered_on']
      }.compact_blank
    end

    def active_label(value)
      { 'Y' => "\uc0ac\uc6a9", 'N' => "\ubbf8\uc0ac\uc6a9" }[value]
    end

    def active_badge_class(value)
      value == 'Y' ? 'badge badge-success badge-outline' : 'badge badge-ghost'
    end

    def row_status_class(value)
      value == 'Y' ? 'is-active' : 'is-inactive'
    end
  end
end
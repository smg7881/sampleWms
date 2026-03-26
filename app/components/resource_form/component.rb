module ResourceForm
  class Component < ApplicationComponent
    ALLOWED_FIELD_KEYS = %i[
      field type label label_key placeholder placeholder_key span options required disabled readonly value target
      pattern minlength maxlength inputmode autocomplete date_type min max step rows include_blank help
      depends_on depends_filter popup_type code_field hide_display display_width code_width button_width
      control_width control_max_width control_min_width multiple multi searchable tom_select input_type
      action_button
    ].freeze

    VALID_FIELD_NAME = /\A[a-zA-Z0-9_]+\z/
    FIELD_TYPES = %w[input number select date_picker textarea checkbox radio switch popup].freeze

    def initialize(model:, fields:, url: nil, method: nil, cols: 3, title: nil, description: nil,
                   show_buttons: true, submit_label: "저장", cancel_url: nil, form_data: {}, form_html: {},
                   target_controller: nil, **html_options)
      @model = model
      @fields = sanitize_fields(fields)
      @url = url
      @form_method = method
      @cols = cols
      @title = title
      @description = description
      @show_buttons = show_buttons
      @submit_label = submit_label
      @cancel_url = cancel_url
      @form_data = form_data
      @form_html = form_html
      @target_controller = target_controller
      @html_options = html_options
    end

    private

    attr_reader :model, :fields, :url, :form_method, :cols, :title, :description,
                :show_buttons, :submit_label, :cancel_url, :form_data, :form_html,
                :target_controller, :html_options

    def wrapper_attrs
      options = html_options.deep_dup
      data = (options.delete(:data) || {}).deep_dup
      data[:controller] = [data[:controller], 'resource-form'].compact.join(' ')
      data[:resource_form_dependencies_value] = dependencies.to_json
      data[:resource_form_loading_value] = false

      {
        class: ['resource-form-shell', options.delete(:class)].compact.join(' '),
        data: data
      }.merge(options)
    end

    def form_options
      {
        model: model,
        url: url,
        method: form_method,
        data: merged_form_data,
        html: merged_form_html
      }.compact
    end

    def merged_form_data
      {
        resource_form_target: 'form',
        action: 'submit->resource-form#submit'
      }.merge(form_data)
    end

    def merged_form_html
      {
        novalidate: true,
        class: 'resource-form-shell__form'
      }.merge(form_html)
    end

    def dependencies
      fields.each_with_object({}) do |field, memo|
        next unless field[:depends_on].present?

        memo[field[:field].to_s] = {
          parent: field[:depends_on].to_s,
          filter_key: (field[:depends_filter] || field[:depends_on]).to_s
        }
      end
    end

    def sanitize_fields(raw_fields)
      Array(raw_fields).map do |field|
        normalized = field.to_h.symbolize_keys.slice(*ALLOWED_FIELD_KEYS)
        normalized[:type] = normalized[:type].to_s.tr('-', '_')

        validate_field_name!(normalized[:field])
        validate_type!(normalized[:type])

        if normalized[:type] == 'popup'
          raise ArgumentError, 'popup field requires popup_type' if normalized[:popup_type].blank?
          raise ArgumentError, 'popup field requires code_field' if normalized[:code_field].blank?

          validate_field_name!(normalized[:code_field])
        end

        normalized
      end
    end

    def validate_field_name!(value)
      raise ArgumentError, "Invalid field name: #{value.inspect}" unless value.present? && value.to_s.match?(VALID_FIELD_NAME)
    end

    def validate_type!(value)
      raise ArgumentError, "Unsupported field type: #{value.inspect}" unless FIELD_TYPES.include?(value)
    end
  end
end

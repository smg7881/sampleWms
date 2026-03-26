module Ui
  module FormFields
    class RendererComponent < ApplicationComponent
      def initialize(fields:, values:, mode:, cols: 3, form: nil, model: nil, target_controller: nil)
        @fields = fields.map { |field| normalize_field(field) }
        @values = values.to_h.transform_keys(&:to_s)
        @mode = mode
        @cols = cols
        @form = form
        @model = model
        @target_controller = target_controller
      end

      private

      attr_reader :fields, :values, :mode, :cols, :form, :model, :target_controller

      def field_partial(field)
        field.fetch(:type)
      end

      def field_locals(field)
        {
          mode: mode,
          form: form,
          model: model,
          target_controller: target_controller,
          field: field,
          wrapper_class: wrapper_class_for(mode),
          wrapper_style: span_style_for(field),
          wrapper_data: wrapper_data(field),
          control_style: control_style_for(field),
          field_id: field_id_for(field[:field]),
          input_name: input_name_for(field[:field]),
          field_value: value_for(field[:field]),
          code_field_id: field_id_for(field[:code_field]),
          code_input_name: input_name_for(field[:code_field]),
          code_field_value: value_for(field[:code_field]),
          label_text: resolve_label(field),
          placeholder_text: resolve_placeholder(field),
          help_text: field[:help],
          normalized_options: normalized_options_for(field),
          selected_values: selected_values_for(field),
          checked: checked?(field[:field]),
          from_id: "q_#{field[:field]}_from",
          to_id: "q_#{field[:field]}_to",
          from_name: "q[#{field[:field]}_from]",
          to_name: "q[#{field[:field]}_to]",
          from_value: value_for("#{field[:field]}_from"),
          to_value: value_for("#{field[:field]}_to"),
          action_button: normalize_action_button(field),
          has_error: error_text_for(field).present?,
          error_text: error_text_for(field),
          code_error_text: code_error_text_for(field),
          input_data: input_data_for(field),
          popup_button_data: popup_button_data_for(field),
          popup_items_json: popup_items_json_for(field),
          popup_title_text: popup_title_text_for(field)
        }
      end

      def wrapper_class_for(current_mode)
        current_mode == :model ? 'resource-form-field' : 'search-form-field'
      end

      def wrapper_data(field)
        data = { field_name: field[:field] }

        if mode == :model
          data[:resource_form_target] = field[:depends_on].present? ? 'fieldGroup dependentField' : 'fieldGroup'
        else
          data[:search_form_target] = 'fieldGroup'
        end

        data
      end

      def input_data_for(field)
        return {} unless mode == :model

        data = { resource_form_target: 'input' }
        actions = ['blur->resource-form#validateField']
        actions << 'change->resource-form#onSelectChange' if field[:type] == 'select'
        data[:action] = actions.join(' ')

        if field[:depends_on].present?
          data[:all_options] = Array(field[:options]).to_json
          data[:depends_on] = field[:depends_on]
          data[:depends_filter] = field[:depends_filter] || field[:depends_on]
          data[:placeholder] = resolve_placeholder(field) || '선택하세요'
        end

        if field[:target].present? && target_controller.present?
          data["#{target_controller.tr('-', '_')}_target"] = field[:target]
        end

        data
      end

      def popup_button_data_for(_field)
        mode == :model ? { action: 'click->search-popup#open' } : {}
      end

      def popup_items_json_for(field)
        return '[]' unless mode == :model && field[:type] == 'popup'

        items = Array(field[:options]).map do |item|
          raw = item.to_h
          {
            label: (raw[:label] || raw['label'] || raw[:value] || raw['value']).to_s,
            value: (raw[:value] || raw['value'] || raw[:code] || raw['code']).to_s,
            display: (raw[:display] || raw['display'] || raw[:label] || raw['label'] || raw[:value] || raw['value']).to_s,
            meta: (raw[:meta] || raw['meta']).to_s
          }
        end

        items.to_json
      end

      def popup_title_text_for(field)
        "#{resolve_label(field)} 선택"
      end

      def normalize_field(field)
        normalized = field.to_h.transform_keys(&:to_sym)
        normalized[:type] = normalized[:type].to_s.tr('-', '_')
        normalized
      end

      def resolve_label(field)
        return field[:label] if field[:label].present?
        return I18n.t(field[:label_key]) if field[:label_key].present?

        field[:field].to_s.humanize
      end

      def resolve_placeholder(field)
        return field[:placeholder] if field[:placeholder].present?
        return I18n.t(field[:placeholder_key]) if field[:placeholder_key].present?

        nil
      end

      def normalized_options_for(field)
        options = Array(field[:options]).map do |option|
          case option
          when Hash
            label = option[:label] || option['label'] || option[:value] || option['value']
            value = option[:value] || option['value']
          when Array
            label, value = option
          else
            label = option
            value = option
          end

          { label: label.to_s, value: value.to_s, selected: selected_values_for(field).include?(value.to_s) }
        end

        return options if field[:include_blank] == false || field[:multi] || field[:multiple] || field[:type] == 'popup'

        [{ label: resolve_placeholder(field) || default_blank_label, value: '', selected: selected_values_for(field).blank? || selected_values_for(field) == [''] }] + options
      end

      def normalize_action_button(field)
        raw = field[:action_button]
        return nil unless raw.present?

        options = raw.to_h.transform_keys(&:to_sym)
        {
          icon: options[:icon].presence || 'search',
          label: options[:label],
          aria_label: options[:aria_label].presence || "#{resolve_label(field)} 조회"
        }
      end

      def value_for(name)
        return '' if name.blank?
        return values[name.to_s].to_s if mode == :search
        return model.public_send(name).to_s if model.respond_to?(name)

        ''
      end

      def checked?(name)
        %w[1 true on yes Y].include?(value_for(name))
      end

      def selected_values_for(field)
        raw = value_for(field[:field])
        return Array(raw).map(&:to_s) if field[:multi] || field[:multiple]

        [raw.to_s]
      end

      def error_text_for(field)
        return nil unless mode == :model && model&.errors

        model.errors[field[:field].to_sym].first
      end

      def code_error_text_for(field)
        return nil unless mode == :model && model&.errors && field[:code_field].present?

        model.errors[field[:code_field].to_sym].first
      end

      def field_id_for(name)
        return "q_#{name}" if mode == :search
        return '' if name.blank?

        "#{param_key}_#{name}"
      end

      def input_name_for(name)
        return "q[#{name}]" if mode == :search
        return '' if name.blank?

        "#{param_key}[#{name}]"
      end

      def param_key
        model&.model_name&.param_key || 'resource'
      end

      def default_blank_label
        mode == :search ? '전체' : '선택하세요'
      end

      def span_style_for(field)
        tokens = parse_span(field[:span].presence || default_span_for(cols))
        [
          "--field-span: #{tokens[:base]};",
          "--field-span-sm: #{tokens[:sm] || tokens[:base]};",
          "--field-span-md: #{tokens[:md] || tokens[:sm] || tokens[:base]};",
          "--field-span-lg: #{tokens[:lg] || tokens[:md] || tokens[:sm] || tokens[:base]};"
        ].join(' ')
      end

      def control_style_for(field)
        styles = []
        styles << "width: #{field[:control_width]};" if field[:control_width].present?
        styles << "max-width: #{field[:control_max_width]};" if field[:control_max_width].present?
        styles << "min-width: #{field[:control_min_width]};" if field[:control_min_width].present?
        styles.join(' ')
      end

      def parse_span(span)
        span.to_s.split.each_with_object({ base: 24 }) do |token, memo|
          if token.include?(':')
            key, value = token.split(':', 2)
            memo[{ 's' => :sm, 'm' => :md, 'l' => :lg }.fetch(key, :base)] = value.to_i
          else
            memo[:base] = token.to_i
          end
        end
      end

      def default_span_for(column_count)
        case column_count
        when 2 then '24 s:12'
        when 4 then '24 s:12 m:6'
        else '24 s:12 m:8'
        end
      end
    end
  end
end

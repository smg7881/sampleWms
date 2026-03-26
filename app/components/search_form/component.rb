module SearchForm
  class Component < ApplicationComponent
    def initialize(title:, description:, url:, fields:, values: {}, cols: 3, enable_collapse: true, collapsed_rows: 1, actions_after: nil, actions_span: nil)
      @title = title
      @description = description
      @url = url
      @fields = fields
      @values = values.to_h
      @cols = cols
      @enable_collapse = enable_collapse
      @collapsed_rows = collapsed_rows
      @actions_after = actions_after
      @actions_span = actions_span
    end

    private

    attr_reader :title, :description, :url, :fields, :values, :cols, :enable_collapse, :collapsed_rows, :actions_after, :actions_span

    def collapse_enabled?
      enable_collapse && fields.size > cols
    end

    def fields_before_actions
      return fields unless actions_after.present?

      fields.first(actions_after)
    end

    def fields_after_actions
      return [] unless actions_after.present?

      fields.drop(actions_after)
    end

    def actions_wrapper_style
      return '' if actions_span.blank?

      tokens = actions_span.to_s.split.each_with_object({ base: 24 }) do |token, memo|
        if token.include?(':')
          key, value = token.split(':', 2)
          memo[{ 's' => :sm, 'm' => :md, 'l' => :lg }.fetch(key, :base)] = value.to_i
        else
          memo[:base] = token.to_i
        end
      end

      [
        "--field-span: #{tokens[:base]};",
        "--field-span-sm: #{tokens[:sm] || tokens[:base]};",
        "--field-span-md: #{tokens[:md] || tokens[:sm] || tokens[:base]};",
        "--field-span-lg: #{tokens[:lg] || tokens[:md] || tokens[:sm] || tokens[:base]};"
      ].join(' ')
    end
  end
end
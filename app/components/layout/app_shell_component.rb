module Layout
  class AppShellComponent < ApplicationComponent
    def initialize(brand:, sections:, tabs:, active_tab_id:, panels:)
      @brand = brand
      @sections = sections
      @tabs = tabs
      @active_tab_id = active_tab_id
      @panels = panels
    end

    private

    attr_reader :brand, :sections, :tabs, :active_tab_id, :panels

    def active_trail
      tabs.find { |tab| tab[:id] == active_tab_id }&.dig(:trail) ||
        panels.fetch(active_tab_id).fetch(:eyebrow).split(" / ").join(" / ")
    end
  end
end

module Layout
  class TabBarComponent < ApplicationComponent
    def initialize(tabs:, active_tab_id:)
      @tabs = tabs
      @active_tab_id = active_tab_id
    end

    private

    attr_reader :tabs, :active_tab_id
  end
end

module Workspace
  class PanelComponent < ApplicationComponent
    def initialize(panel:, active:)
      @panel = panel
      @active = active
    end

    private

    attr_reader :panel, :active

    def tone_class
      "tone-#{panel[:tone]}"
    end
  end
end

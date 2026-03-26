module Ui
  class ResourceFormComponent < ApplicationComponent
    def initialize(**options)
      @options = options
    end

    private

    attr_reader :options
  end
end

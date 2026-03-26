module ResourceForm
  class HeaderComponent < ApplicationComponent
    def initialize(title:, description: nil)
      @title = title
      @description = description
    end

    private

    attr_reader :title, :description
  end
end

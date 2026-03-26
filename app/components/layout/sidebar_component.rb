module Layout
  class SidebarComponent < ApplicationComponent
    def initialize(brand:, sections:)
      @brand = brand
      @sections = sections
    end

    private

    attr_reader :brand, :sections
  end
end

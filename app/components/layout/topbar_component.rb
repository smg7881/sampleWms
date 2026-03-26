module Layout
  class TopbarComponent < ApplicationComponent
    def initialize(brand:, active_trail:)
      @brand = brand
      @active_trail = active_trail
    end

    private

    attr_reader :brand, :active_trail
  end
end

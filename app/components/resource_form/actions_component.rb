module ResourceForm
  class ActionsComponent < ApplicationComponent
    def initialize(submit_label:, cancel_url: nil)
      @submit_label = submit_label
      @cancel_url = cancel_url
    end

    private

    attr_reader :submit_label, :cancel_url
  end
end

class ApplicationComponent < ViewComponent::Base
  delegate :ui_icon, to: :helpers
end

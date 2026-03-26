module ResourceFormHelper
  def resource_form_tag(**options)
    render ResourceForm::Component.new(**options)
  end
end

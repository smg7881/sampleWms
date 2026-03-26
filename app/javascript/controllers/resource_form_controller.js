import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "fieldGroup", "input", "submitBtn", "submitText", "submitSpinner", "resetBtn", "buttonGroup", "errorSummary"]
  static values = { loading: Boolean, dependencies: Object }

  connect() {
    this.initializeDependencies()
  }

  submit(event) {
    if (this.loadingValue) {
      event.preventDefault()
      return
    }

    if (!this.formTarget.checkValidity()) {
      event.preventDefault()
      this.formTarget.reportValidity()
      this.highlightInvalidFields()
      return
    }

    this.loadingValue = true
  }

  reset(event) {
    event.preventDefault()
    this.formTarget.reset()
    this.loadingValue = false
    this.clearErrors()
    this.initializeDependencies()
  }

  validateField(event) {
    const input = event.target
    const fieldGroup = input.closest("[data-field-name]")
    if (!fieldGroup) return

    if (input.checkValidity()) {
      input.classList.remove("resource-form-control--error")
      this.hideFieldError(fieldGroup)
    } else {
      input.classList.add("resource-form-control--error")
      this.showFieldError(fieldGroup, input.validationMessage)
    }
  }

  onSelectChange(event) {
    const parent = event.target.closest("[data-field-name]")
    if (!parent) return

    this.updateDependentFields(parent.dataset.fieldName, event.target.value)
  }

  loadingValueChanged() {
    if (this.hasSubmitBtnTarget) this.submitBtnTarget.disabled = this.loadingValue
    if (this.hasSubmitSpinnerTarget) this.submitSpinnerTarget.hidden = !this.loadingValue
  }

  noop() {}

  initializeDependencies() {
    if (!this.hasDependenciesValue) return

    Object.entries(this.dependenciesValue).forEach(([_, config]) => {
      const parent = this.element.querySelector(`[data-field-name="${config.parent}"] select`)
      if (parent) this.updateDependentFields(config.parent, parent.value)
    })
  }

  updateDependentFields(parentName, parentValue) {
    Object.entries(this.dependenciesValue || {}).forEach(([childField, config]) => {
      if (config.parent !== parentName) return

      const childSelect = this.element.querySelector(`[data-field-name="${childField}"] select`)
      if (!childSelect) return

      const allOptionsJson = childSelect.dataset.allOptions
      if (!allOptionsJson) return

      let allOptions = []
      try {
        allOptions = JSON.parse(allOptionsJson)
      } catch (_error) {
        return
      }

      const placeholder = childSelect.dataset.placeholder || "선택하세요"
      const filtered = parentValue
        ? allOptions.filter((option) => String(option[config.filter_key] ?? option[`${config.filter_key}`]) === String(parentValue))
        : allOptions

      childSelect.innerHTML = ""
      childSelect.add(new Option(placeholder, ""))
      filtered.forEach((option) => {
        childSelect.add(new Option(option.label ?? option["label"], option.value ?? option["value"]))
      })
    })
  }

  highlightInvalidFields() {
    this.inputTargets.forEach((input) => {
      if (!input.checkValidity()) input.classList.add("resource-form-control--error")
    })
  }

  clearErrors() {
    this.element.querySelectorAll(".resource-form-control--error").forEach((element) => {
      element.classList.remove("resource-form-control--error")
    })

    this.element.querySelectorAll(".resource-form-field__error").forEach((element) => {
      if (!element.dataset.serverError) {
        element.textContent = " "
        element.hidden = true
      }
    })

    if (this.hasErrorSummaryTarget) this.errorSummaryTarget.remove()
  }

  showFieldError(fieldGroup, message) {
    let errorElement = fieldGroup.querySelector(".resource-form-field__error")
    if (!errorElement) {
      errorElement = document.createElement("p")
      errorElement.className = "resource-form-field__error"
      fieldGroup.appendChild(errorElement)
    }
    errorElement.hidden = false
    errorElement.textContent = message
  }

  hideFieldError(fieldGroup) {
    const errorElement = fieldGroup.querySelector(".resource-form-field__error")
    if (!errorElement || errorElement.dataset.serverError) return

    errorElement.textContent = " "
    errorElement.hidden = true
  }
}

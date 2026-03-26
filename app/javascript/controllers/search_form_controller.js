import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static targets = ["form", "fieldGroup", "actions", "collapseButton", "collapseLabel"]
  static values = { collapsed: Boolean, collapsedRows: Number }

  connect() {
    this.updateCollapseState()
  }

  search(event) {
    if (this.formTarget.checkValidity()) return

    event.preventDefault()
    this.formTarget.reportValidity()
  }

  reset(event) {
    event.preventDefault()
    this.formTarget.reset()

    const url = new URL(this.formTarget.action, window.location.origin)
    Turbo.visit(url.pathname)
  }

  toggleCollapse() {
    this.collapsedValue = !this.collapsedValue
  }

  collapsedValueChanged() {
    this.updateCollapseState()
  }

  updateCollapseState() {
    if (!this.hasCollapseButtonTarget) return

    const actionSpan = this.hasActionsTarget ? this.spanOf(this.actionsTarget) : 0
    const limit = (this.collapsedRowsValue * 24) - actionSpan
    let consumed = 0

    this.fieldGroupTargets.forEach((field) => {
      if (!this.collapsedValue) {
        field.hidden = false
        return
      }

      const span = this.spanOf(field)
      const shouldShow = consumed + span <= limit || consumed === 0
      field.hidden = !shouldShow
      if (shouldShow) consumed += span
    })

    this.collapseButtonTarget.setAttribute("aria-expanded", (!this.collapsedValue).toString())
    this.collapseLabelTarget.textContent = this.collapsedValue ? "펼침" : "접기"
  }

  spanOf(element) {
    const value = getComputedStyle(element).gridColumnEnd
    const match = String(value).match(/span\s+(\d+)/)
    return match ? parseInt(match[1], 10) : 24
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "query", "list", "empty", "display", "code", "title"]
  static values = { items: Array, title: String }

  connect() {
    this.filteredItems = this.itemsValue || []
    this.render()
  }

  open() {
    if (this.hasTitleTarget) this.titleTarget.textContent = this.titleValue
    this.filteredItems = this.itemsValue || []
    if (this.hasQueryTarget) this.queryTarget.value = ""
    this.render()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  filter() {
    const query = (this.queryTarget.value || "").trim().toLowerCase()
    const items = this.itemsValue || []

    this.filteredItems = query.length === 0
      ? items
      : items.filter((item) => {
          return [item.label, item.value, item.display, item.meta].some((value) => String(value || "").toLowerCase().includes(query))
        })

    this.render()
  }

  select(event) {
    const { value, display } = event.currentTarget.dataset
    if (this.hasCodeTarget) {
      this.codeTarget.value = value
      this.codeTarget.dispatchEvent(new Event("input", { bubbles: true }))
      this.codeTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
    if (this.hasDisplayTarget) {
      this.displayTarget.value = display
      this.displayTarget.dispatchEvent(new Event("input", { bubbles: true }))
      this.displayTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
    this.close()
  }

  render() {
    if (!this.hasListTarget) return

    this.listTarget.innerHTML = ""
    this.filteredItems.forEach((item) => {
      const row = document.createElement("tr")
      row.innerHTML = `
        <td>${this.escape(item.value)}</td>
        <td>${this.escape(item.display || item.label)}</td>
        <td>${this.escape(item.meta || "-")}</td>
        <td>
          <button type="button" class="btn btn-sm btn-primary" data-action="click->search-popup#select" data-value="${this.escapeAttr(item.value)}" data-display="${this.escapeAttr(item.display || item.label)}">선택</button>
        </td>
      `
      this.listTarget.appendChild(row)
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = this.filteredItems.length > 0
  }

  escape(value) {
    return String(value ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }

  escapeAttr(value) {
    return this.escape(value)
  }
}

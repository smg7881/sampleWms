import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["breadcrumb", "menuItem", "panel", "tab", "tabList"]
  static values = { activeTab: String }

  connect() {
    this.activateTabById(this.activeTabValue || "overview")
  }

  toggleSidebar() {
    this.element.classList.toggle("app-shell--collapsed")
  }

  openTab(event) {
    const { tabId, tabLabel, tabTrail } = event.currentTarget.dataset

    if (!this.tabFor(tabId)) {
      this.tabListTarget.insertAdjacentHTML("beforeend", this.tabMarkup(tabId, tabLabel, tabTrail))
      document.dispatchEvent(new Event("lucide:refresh"))
    }

    this.activateTabById(tabId)
  }

  activateTab(event) {
    this.activateTabById(event.currentTarget.dataset.tabId)
  }

  closeTab(event) {
    event.preventDefault()
    event.stopPropagation()

    const tab = event.currentTarget.closest("[data-role='workspace-tab']")
    if (!tab) return

    const closingId = tab.dataset.tabId
    tab.remove()

    if (closingId === this.activeTabValue) {
      const fallback = this.tabTargets[this.tabTargets.length - 1]?.dataset?.tabId || "overview"
      this.activateTabById(fallback)
    }
  }

  filterMenus(event) {
    const query = event.currentTarget.value.trim().toLowerCase()

    document.querySelectorAll("[data-role='sidebar-section']").forEach((section) => {
      const items = section.querySelectorAll("[data-role='sidebar-item']")
      let visibleCount = 0

      items.forEach((item) => {
        const matches = query.length === 0 || item.innerText.toLowerCase().includes(query)
        item.hidden = !matches
        if (matches) visibleCount += 1
      })

      section.hidden = visibleCount === 0

      if (query.length > 0 && visibleCount > 0) {
        const trigger = section.querySelector(".sidebar-section__trigger")
        const body = section.querySelector(".sidebar-section__body")
        trigger?.classList.add("is-open")
        trigger?.setAttribute("aria-expanded", "true")
        body?.classList.add("is-open")
      }
    })
  }

  activateTabById(tabId) {
    this.activeTabValue = tabId

    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.tabId === tabId
      tab.classList.toggle("is-active", isActive)
      tab.setAttribute("aria-selected", isActive.toString())
    })

    this.panelTargets.forEach((panel) => {
      panel.hidden = panel.dataset.panelId !== tabId
    })

    this.menuItemTargets.forEach((item) => {
      item.classList.toggle("is-active", item.dataset.tabId === tabId)
    })

    const tab = this.tabFor(tabId) || this.menuItemTargets.find((item) => item.dataset.tabId === tabId)
    if (this.hasBreadcrumbTarget && tab) {
      this.breadcrumbTarget.textContent = tab.dataset.tabTrail
    }
  }

  tabFor(tabId) {
    return this.tabTargets.find((tab) => tab.dataset.tabId === tabId)
  }

  tabMarkup(tabId, label, trail) {
    return `
      <button
        type="button"
        class="workspace-tab"
        data-shell-target="tab"
        data-role="workspace-tab"
        data-action="click->shell#activateTab"
        data-tab-id="${tabId}"
        data-tab-label="${label}"
        data-tab-trail="${trail}"
        aria-selected="false">
        <span class="workspace-tab__dot"></span>
        <span class="workspace-tab__label">${label}</span>
        <span class="workspace-tab__close" data-action="click->shell#closeTab" aria-label="${label} 닫기">×</span>
      </button>
    `
  }
}

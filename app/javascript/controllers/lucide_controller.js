import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.renderIcons = this.renderIcons.bind(this)

    this.renderIcons()

    document.addEventListener("turbo:load", this.renderIcons)
    document.addEventListener("turbo:frame-load", this.renderIcons)
    document.addEventListener("turbo:render", this.renderIcons)
    document.addEventListener("lucide:refresh", this.renderIcons)
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.renderIcons)
    document.removeEventListener("turbo:frame-load", this.renderIcons)
    document.removeEventListener("turbo:render", this.renderIcons)
    document.removeEventListener("lucide:refresh", this.renderIcons)
  }

  renderIcons() {
    window.lucide?.createIcons()
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleSection(event) {
    const trigger = event.currentTarget
    const body = trigger.nextElementSibling
    const isOpen = trigger.classList.toggle("is-open")

    if (body) {
      body.classList.toggle("is-open", isOpen)
    }

    trigger.setAttribute("aria-expanded", isOpen.toString())
  }
}

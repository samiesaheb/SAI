import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count"]

  connect() {
    this.update()
  }

  update() {
    const checked = this.element.querySelectorAll("input[type='checkbox']:checked").length
    this.countTarget.textContent = `${checked} selected`
    this.countTarget.hidden = checked === 0
  }
}

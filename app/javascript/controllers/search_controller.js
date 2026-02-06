import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "clear"]

  connect() {
    this.toggleClear()
  }

  toggleClear() {
    this.clearTarget.hidden = this.inputTarget.value.trim() === ""
  }

  clear() {
    this.inputTarget.value = ""
    this.toggleClear()
    this.inputTarget.focus()
  }

  submit(event) {
    if (this.inputTarget.value.trim() === "") {
      event.preventDefault()
    }
  }
}

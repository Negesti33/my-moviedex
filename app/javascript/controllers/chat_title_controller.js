import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "form"]

  edit() {
    this.titleTarget.classList.add("d-none")
    this.formTarget.classList.remove("d-none")
  }

  cancel() {
    this.titleTarget.classList.remove("d-none")
    this.formTarget.classList.add("d-none")
  }
}

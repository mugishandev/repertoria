import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets= ["link"]

  connect() {
  }

  select(event) {
    this.linkTargets.forEach(l => l.classList.remove("active"))
    event.currentTarget.classList.add("active")
  }
}

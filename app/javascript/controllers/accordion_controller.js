import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]

  toggle() {
    // Affiche ou masque le contenu du dropdown
    this.contentTarget.classList.toggle("is-open")

    // Anime la petite flèche (rotation)
    if (this.hasIconTarget) {
      this.iconTarget.classList.toggle("is-rotated")
    }
  }
}

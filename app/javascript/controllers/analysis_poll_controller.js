import { Controller } from "@hotwired/stimulus"

// Interroge doucement /analyse/status pendant que AnalyseRepertoireJob tourne.
// done  -> navigation vers le dashboard
// error -> remplace le loader par le message et un lien retour
export default class extends Controller {
  static values = {
    url: String,
    interval: { type: Number, default: 2000 }
  }

  connect() {
    this.stopped = false
    this.poll()
  }

  disconnect() {
    this.stopped = true
    if (this.timer) clearTimeout(this.timer)
  }

  async poll() {
    if (this.stopped) return

    try {
      const response = await fetch(this.urlValue, {
        headers: { Accept: "application/json" }
      })
      const data = await response.json()

      if (data.state === "done") {
        window.location.href = data.redirect_to || "/openings"
        return
      }

      if (data.state === "error") {
        this.showError(data.message, data.redirect_to || "/")
        return
      }
    } catch (e) {
      // erreur réseau ponctuelle : on retente au prochain tick
    }

    this.timer = setTimeout(() => this.poll(), this.intervalValue)
  }

  showError(message, href) {
    this.stopped = true
    const text = message || "Une erreur est survenue pendant l'analyse. Réessaie."
    this.element.innerHTML =
      `<p class="analyse-loading-text">${text}</p>` +
      `<a class="analyse-loading-link" href="${href}">Retour à l'accueil</a>`
  }
}

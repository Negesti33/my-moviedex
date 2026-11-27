import { Controller } from "@hotwired/stimulus"

// Fait tourner les affiches toutes les 3 secondes
export default class extends Controller {
  static targets = ["poster"]

  connect() {
    // pas d'animation si elle est désactivée sur l'appareil
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.timer = setInterval(() => this.next(), 3000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  next() {
    // je garde la position de chaque affiche
    const before = new Map(this.posterTargets.map(p => [p, p.getBoundingClientRect()]))

    // la première passe à la fin
    const first = this.posterTargets[0]
    this.element.appendChild(first)

    // chaque affiche glisse vers sa nouvelle place
    this.posterTargets.forEach(p => {
      if (p === first) {
        p.animate([{ opacity: 0 }, { opacity: 1 }], { duration: 700, easing: "ease" })
        return
      }
      const b = before.get(p)
      const a = p.getBoundingClientRect()
      const dx = b.left - a.left
      const dy = b.top - a.top
      const sx = b.width / a.width
      const sy = b.height / a.height
      p.animate(
        [
          { transformOrigin: "top left", transform: `translate(${dx}px, ${dy}px) scale(${sx}, ${sy})` },
          { transformOrigin: "top left", transform: "none" }
        ],
        { duration: 700, easing: "cubic-bezier(.4, 0, .2, 1)" }
      )
    })
  }
}

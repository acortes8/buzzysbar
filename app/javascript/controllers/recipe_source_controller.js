import { Controller } from "@hotwired/stimulus"

// Shows only the fields that apply to the chosen source: a book and page for
// a book, a name for a bartender or bar. The server ignores the others anyway.
export default class extends Controller {
  static targets = [ "select", "details" ]

  connect() {
    this.toggle()
  }

  toggle() {
    this.detailsTargets.forEach((details) => {
      details.hidden = !details.dataset.sources.split(" ").includes(this.selectTarget.value)
    })
  }
}

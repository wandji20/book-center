import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.request = null;
  }

  submit() {
    clearTimeout(this.request)

    this.request = setTimeout(() => {
      this.element.requestSubmit();
    }, 300);
  }
}
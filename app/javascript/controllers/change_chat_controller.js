import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  // static targets = [ 'test' ]

  connect() {
    console.log('Hello from change_chat.js')
    // console.log(this.testTarget)
  }
  modify(event) {
    console.log(event.target)
  }

  delete(event) {
    console.log(event)
  }
}

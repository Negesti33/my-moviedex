import { Controller } from "@hotwired/stimulus";

// Valeurs par défaut : Vieux Lyon
const DEFAULT_LATITUDE = 45.757387;
const DEFAULT_LONGITUDE = 4.832794;

export default class extends Controller {
  static targets = ["button", "status"];
  static values = { url: String };

  connect() {
    // optionnel : récupérer la position dès l'arrivée sur la page
    // this.locate();
  }

  locate() {
    const defaultLocation = "La géolocation n'est pas activée, recherche par défaut autour du Vieux-Lyon.";
    if (!navigator.geolocation) {
      this.sendToServer(DEFAULT_LATITUDE, DEFAULT_LONGITUDE, defaultLocation);
      return;
    }

    this.statusTarget.textContent = "Locating…";

    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords;
        this.sendToServer(latitude, longitude, null);
      },
      (error) => {
        console.log(error.message);
        this.sendToServer(DEFAULT_LATITUDE, DEFAULT_LONGITUDE, defaultLocation);
      }
    );
  }

  sendToServer(latitude, longitude, message) {
    const token = document.querySelector("meta[name='csrf-token']").content;

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
      },
      body: JSON.stringify({ latitude, longitude }),
    })
      .then((response) => {
        if (!response.ok) throw new Error("La requête a échoué");
        if (message) this.statusTarget.textContent = message;
      })
      .catch((error) => {
        this.statusTarget.textContent = "La géolocalisation n'a pas pu être sauvegardée.";
        console.error(error);
      });
  }
}

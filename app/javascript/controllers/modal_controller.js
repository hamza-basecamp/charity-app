import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modal"];

  open(event) {
    const modal = document.getElementById("edit-modal");
    const charityId = event.currentTarget.dataset.modalCharityId;
    const charityName = event.currentTarget.dataset.modalCharityName;
    const commissionRate = event.currentTarget.dataset.modalCharityRate;

    modal.querySelector("#charity-id").value = charityId;
    modal.querySelector("#commission-rate").value = commissionRate;
    modal.querySelector("#commission-type").value = charityName;

    modal.classList.remove("hidden");
  }

  close() {
    const modal = document.getElementById("edit-modal");
    modal.classList.add("hidden");
  }
}

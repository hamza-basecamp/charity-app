document.addEventListener("turbo:submit-end", (event) => {
  if (event.detail.success) {
    document.getElementById("edit-modal").classList.add("hidden");
  }
});

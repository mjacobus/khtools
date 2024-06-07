// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import Rails from "@rails/ujs";
import { on } from "delegated-events";

Rails.start();

on("click", "[data-toggle-sidebar]", () => {
  const content = document.getElementById("content");
  const sidebar = document.getElementById("sidebar");

  content.classList.toggle("sidebar-hidden");
  sidebar.classList.toggle("hidden");
});


on("click", "[data-clipboard-selector]", async (event) => {
  event.preventDefault();
  let button = event.target;
  if (button.tagName !== "BUTTON") {
    button = button.parentElement;
  }
  const confirmation = button.querySelector(
    "[data-clipboard-copy-confirmation]"
  );
  const icon = button.querySelector("[data-clipboard-icon]");
  const selector = button.getAttribute("data-clipboard-selector");
  const element = document.querySelector(selector);
  console.log(button, icon, confirmation);

  confirmation.hidden = false;
  icon.hidden = true;
  setTimeout(() => {
    confirmation.hidden = true;
    icon.hidden = false;
  }, 1000);
  await navigator.clipboard.writeText(element.innerText);
});

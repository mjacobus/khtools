// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import Rails from "@rails/ujs";
import { on } from "delegated-events";

Rails.start();

// Sidebar
on("click", "[data-toggle-sidebar]", () => {
  const content = document.getElementById("content");
  const sidebar = document.getElementById("sidebar");

  content.classList.toggle("sidebar-hidden");
  sidebar.classList.toggle("hidden");
});

// Clipboard
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
  const selector = button.getAttribute("data-clipboardl-selector");
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

// Talks form
on('change', '.PublicTalks_Talks_FormPageComponent__special_flag', (event) => {
  const special = event.target.checked;
  const selectContainer = document.querySelector('.PublicTalks_Talks_FormPageComponent__theme_select_container')
  const select = selectContainer.querySelector('select')
  const textContainer = document.querySelector('.PublicTalks_Talks_FormPageComponent__theme_text_container')
  const text = textContainer.querySelector('input')

  select.disabled = special
  selectContainer.hidden = special
  text.disabled = !special
  textContainer.hidden = !special
})

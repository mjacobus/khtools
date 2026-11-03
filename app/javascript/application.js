// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import Rails from "@rails/ujs";
import { on } from "delegated-events";

Rails.start();

// Searchable selects
//
// Selects with more than SEARCHABLE_SELECT_MIN_OPTIONS options get a text
// filter. data-searchable="true" forces it, data-searchable="false" opts out.
// The original <select> keeps its value, so form submissions don't change.
// TomSelect is loaded from the CDN in the layout.
const SEARCHABLE_SELECT_MIN_OPTIONS = 8;

// Rails date/time selects name their parts like "talk[date(3i)]".
const DATE_PART_SELECT = /\(\di\)\]$/;

function shouldBeSearchable(select) {
  if (select.multiple || select.tomselect || DATE_PART_SELECT.test(select.name)) {
    return false;
  }

  const flag = select.dataset.searchable;

  if (flag === "true") {
    return true;
  }

  if (flag === "false") {
    return false;
  }

  return select.options.length > SEARCHABLE_SELECT_MIN_OPTIONS;
}

function makeSearchable(select) {
  new window.TomSelect(select, {
    allowEmptyOption: true,
    maxOptions: null,
    placeholder: "Digite para filtrar…",
    render: {
      no_results: () => '<div class="no-results">Nenhum resultado</div>',
    },
  });
}

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("select").forEach((select) => {
    if (shouldBeSearchable(select)) {
      makeSearchable(select);
    }
  });
});

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
  const selector = button.getAttribute("data-clipboard-selector");
  const element = document.querySelector(selector);

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

window.fetchAddress = function (params) {
  getCurrentLocationAndAddress().then((data) => {
    let message = `Query usar esse endereço? ${data.formatted_address}?`

    if (confirm(message)) {
      document.querySelector(params.longitudeSelector).value = data.longitude
      document.querySelector(params.latitudeSelector).value = data.latitude
      document.querySelector(params.addressSelector).value = data.formatted_address
    }
  })
}

async function getCurrentLocationAndAddress() {
  if (!navigator.geolocation) {
    return Promise.reject('Geolocation is not supported by this browser.');
  }

  return new Promise((resolve, reject) => {
    navigator.geolocation.getCurrentPosition(async (position) => {
      const latitude = position.coords.latitude;
      const longitude = position.coords.longitude;
      const apiKey = await fetchGoogleMapsApiKey()

      try {
        const response = await fetch(`https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${apiKey}`);

        if (response.ok) {
          const data = await response.json();

          if (data.status === 'OK' && data.results.length > 0) {
            const formatted_address = data.results[0].formatted_address;
            return resolve({ formatted_address, latitude, longitude });
          }

          return reject(`No address found: ${data.status}`);
        } else {
          reject(`Error fetching address: ${response.status}`);
        }
      } catch (error) {
        return reject(`Request failed: ${error}`);
      }
    }, (error) => {
      reject(`Geolocation error: ${error.message}`);
    });
  });
}

async function fetchGoogleMapsApiKey() {
  const cachedConfig = localStorage.getItem('config');

  // If cached config exists, parse and return the API key
  if (cachedConfig) {
    const config = JSON.parse(cachedConfig);
    return config.google_maps_static_api_key;
  }

  try {
    const response = await fetch('/config', {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    });

    if (response.ok) {
      const data = await response.json();

      // Save the entire JSON response in localStorage under 'config'
      localStorage.setItem('config', JSON.stringify(data));

      // Return the specific API key from the data
      return data.google_maps_static_api_key;
    } else {
      console.error('Failed to fetch config:', response.status);
      throw new Error('Failed to retrieve Google Maps config');
    }
  } catch (error) {
    console.error('Request failed:', error);
    throw new Error('Request to fetch Google Maps config failed');
  }
}


on("click", "[data-insert-lat-lon]", async (event) => {
  event.preventDefault();
  let url = event.target.href;

  if (!navigator.geolocation) {
    window.location.href = url
    return
  }

  navigator.geolocation.getCurrentPosition(async (position) => {
    const latitude = position.coords.latitude;
    const longitude = position.coords.longitude;

    if (!url.includes('?')) {
      url += '?'
    }

    url += `latitude=${latitude}&longitude=${longitude}`
    window.location.href = url
  });
});

// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()

import "../src/application.scss"
import {on} from 'delegated-events'

require("bootstrap") // not enough to enable toggle

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)


on('click', '[data-toggle-sidebar]', () => {
  const content = document.getElementById('content')
  const sidebar = document.getElementById('sidebar')

  content.classList.toggle('sidebar-hidden')
  sidebar.classList.toggle('hidden')
})

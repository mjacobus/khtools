import { on } from "delegated-events";

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

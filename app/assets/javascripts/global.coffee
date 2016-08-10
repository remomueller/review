@authorAssuranceCheck = () ->
  if !$('#publication_author_assurance').is(':checked')
    alert 'Please read and check the Author Assurance and Sign Off'
    return false
  if !confirm('Submit publication for review? No more edits will be possible.')
    return false
  true

@toggleAttachment = (element_id) ->
  checkbox_element = $(element_id)
  file_container = $(element_id + '_container')
  if checkbox_element.is(':checked')
    file_container.show()
  else
    file_container.hide()

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)


@ready = () ->
  contourReady()
  publicationsReady()
  window.$isDirty = false
  msg = "You haven't saved your changes."
  window.onbeforeunload = (el) -> return msg if window.$isDirty
  setFocusToField("#search")

$(document).ready(ready)
$(document)
  .on('page:load', ready)
  .on('mouseover', ".smudge", () -> $(this).attr('src', $(this).attr('src').replace(/(-(.*?))?.png/, '_g1.png')))
  .on('mouseout', ".smudge",  () -> $(this).attr('src', $(this).attr('src').replace(/(-(.*?))?_g1.png/, '.png')))
  .on('click', ".token-input-list-facebook", () -> $(this).parent().find("input").focus()  )
  .on('click', '[data-object~="toggle"]', () ->
    $($(this).data('target')).toggle()
    false
  )
  .on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )

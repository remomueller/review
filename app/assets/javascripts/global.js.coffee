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

jQuery ->
  $(document)
    .on('mouseover', ".smudge", () -> $(this).attr('src', $(this).attr('src').replace(/(-(.*?))?.png/, '_g1.png')))
    .on('mouseout', ".smudge",  () -> $(this).attr('src', $(this).attr('src').replace(/(-(.*?))?_g1.png/, '.png')))
    .on('click', ".token-input-list-facebook", () -> $(this).parent().find("input").focus()  )

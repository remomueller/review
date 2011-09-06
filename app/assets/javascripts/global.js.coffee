# Global functions referenced from HTML
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
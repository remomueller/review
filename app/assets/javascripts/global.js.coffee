# Global functions referenced from HTML
@showWaiting = (element_id, text, centered) ->
  element = $(element_id)
  if element && centered
    element.html('<br /><center><img width=\"13\" height=\"13\" src=\"' + root_url + 'assets/ajax-loader.gif\" align=\"absmiddle\" alt=\"...\" />' + text + '</center><br />')
  else if element
    element.html('<img width=\"13\" height=\"13\" src=\"' + root_url + 'assets/ajax-loader.gif\" align=\"absmiddle\" alt=\"...\" />' + text)

# Mouse Out Functions to Show and Hide Divs

@isTrueMouseOut = (e, handler) ->
	if e.type != 'mouseout' 
	  return false
	
  # relTarget
  if e.relatedTarget
    relTarget = e.relatedTarget
  else if e.type == 'mouseout'
    relTarget = e.toElement
  else
    relTarget = e.fromElement
  while relTarget && relTarget != handler
    relTarget = relTarget.parentNode
  relTarget != handler

@hideOnMouseOut = (elements) ->
  $.each(elements, (index, value) ->
    element = $(value)
    element.mouseout((e, handler) ->
      if isTrueMouseOut(e||window.event, this) then element.hide()
    )
  )

@showMessage = (elements) ->
  $.each(elements, (index, value) ->
    element = $(value)
    element.fadeIn(2000)
  )


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
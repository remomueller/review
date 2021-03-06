@toggleAttachment = (element_id) ->
  checkbox_element = $(element_id)
  file_container = $("#{element_id}_container")
  if checkbox_element.is(':checked')
    file_container.show()
  else
    file_container.hide()

@publicationsReady = ->
  $('#user_publication_review_writing_group_nomination').tokenInput(root_url + 'users.json',
    crossDomain: false
    prePopulate: $('#user_publication_review_writing_group_nomination').data('pre')
    theme: 'facebook', preventDuplicates: true
  )

$(document)
  .on('click', '[data-object~="publication-save"]', ->
    if $(this).data('assurance') and not authorAssuranceCheck()
      false
    else
      window.$isDirty = false
      $('#publish').val($(this).data('publish'))
      $($(this).data('target')).submit()
      false
  )
  .on('click', '[data-object~="modal-show"]', ->
    $($(this).data('target')).modal( 'show' )
    false
  )
  .on('click', '[data-object~="modal-hide"]', ->
    $($(this).data('target')).modal('hide')
    $($(this).data('form-target'))[0].reset()
    $('.' + $(this).data('remove-class')).removeClass($(this).data('remove-class'))
    false
  )
  .on('click', '[data-object~="submit"]', ->
    $($(this).data('target')).submit()
    false
  )
  .on('click', '#myTab a', (e) ->
    e.preventDefault()
    $(this).tab('show')
  )
  .on('click', '[data-object~="publication-secretary-save"]', ->
      window.$isDirty = false
      $($(this).data('target')).submit()
      false
  )
  .on('click', '[data-object~="toggle-attachment"]', ->
    toggleAttachment($(this).data('target'))
  )

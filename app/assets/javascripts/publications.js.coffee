# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $(document)
    .on('click', '[data-object~="publication-save"]', () ->
      if $(this).data('assurance') and not authorAssuranceCheck()
        false
      else
        $('#publish').val($(this).data('publish'))
        $($(this).data('target')).submit()
        false
    )
    .on('click', '[data-object~="modal-show"]', () ->
      $($(this).data('target')).modal( dynamic: true )
      false
    )
  .on('click', '[data-object~="modal-hide"]', () ->
    $($(this).data('target')).modal('hide')
    $($(this).data('form-target'))[0].reset()
    $('.' + $(this).data('remove-class')).removeClass($(this).data('remove-class'))
    false
  )
  .on('click', '[data-object~="submit"]', () ->
    $($(this).data('target')).submit();
    false
  )

# This file will contain application generic JavaScript (CoffeeScript)

jQuery ->
  $(".datepicker").datepicker
    showOtherMonths: true
    selectOtherMonths: true
    changeMonth: true
    changeYear: true

  $("#ui-datepicker-div").hide()
  
  $(document).on('click', ".pagination a, .page a, .next a, .prev a", () ->
    $.get(this.href, null, null, "script")
    false
  )

  $(document).on("click", ".per_page a", () ->
    object_class = $(this).data('object')
    $.get($("#"+object_class+"_search").attr("action"), $("#"+object_class+"_search").serialize() + "&"+object_class+"_per_page="+ $(this).data('count'), null, "script")
    false
  )
  
  $(document)
    .on('mouseover', ".smudge", () -> $(this).attr('src', $(this).attr('src').replace(/(-(.*?))?.png/, '_g1.png')))
    .on('mouseout', ".smudge",  () -> $(this).attr('src', $(this).attr('src').replace(/(-(.*?))?_g1.png/, '.png')))
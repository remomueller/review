// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function createSpinner() {
  return new Element('img', { src: root_url + 'images/ajax-loader.gif', 'class': 'spinner', 'height': '11', 'width': '11' });
}

$(function(){
  $(".datepicker").datepicker({ showOtherMonths: true, selectOtherMonths: true, changeMonth: true, changeYear: true });
  $("#ui-datepicker-div").hide();
  
  $(".pagination a, .page a").live("click", function() {
    // $(".pagination").html(createSpinner()); //.html("Page is loading...");
    $.get(this.href, null, null, "script")
    return false;
  });
  
  // $("input[type='text']").change( function() {
  //   // check input ($(this).val()) for validity here
  // });
  
  $(".field_with_errors input, .field_with_errors_cleared input, .field_with_errors textarea, .field_with_errors_cleared textarea, .field_with_errors select, .field_with_errors_cleared select").change(function() {
    var el = $(this);
    if(el.val() != '' && el.val() != null){
      $(el).parent().removeClass('field_with_errors');
      $(el).parent().addClass('field_with_errors_cleared');
    }else{
      $(el).parent().removeClass('field_with_errors_cleared');
      $(el).parent().addClass('field_with_errors');
    }
        
    // $.get($("#comments_search").attr("action"), $("#comments_search").serialize(), null, "script");
    // return false;
  });
  
});

/* Mouse Out Functions to Show and Hide Divs */

function isTrueMouseOut(e, handler) {
	if (e.type != 'mouseout') return false;
	var relTarget;
  if (e.relatedTarget) {
    relTarget = e.relatedTarget;
  } else if (e.type == 'mouseout') {
    relTarget = e.toElement;
  } else {
    relTarget = e.fromElement;
  }
  while (relTarget && relTarget != handler) {
    relTarget = relTarget.parentNode;
  }
	return (relTarget != handler);
}

function hideOnMouseOut(elements){
  $.each(elements, function(index, value){
    var element = $(value);
    element.mouseout(function(e, handler) {
      if (isTrueMouseOut(e||window.event, this)) element.hide();
    });
  });
}

function showMessage(elements){
  $.each(elements, function(index, value){
    var element = $(value);
    element.fadeIn(2000);
  })
}

function authorAssuranceCheck(){
  if(!$('#publication_author_assurance').is(':checked')){
    alert('Please read and check the Author Assurance and Sign Off');
    return false;
  }
  if(!confirm('Submit publication for review? No more edits will be possible.')){
    return false;
  }
  return true;
}

function toggleAttachment(element_id){
  var checkbox_element = $(element_id);
  var file_container = $(element_id + '_container');
  if(checkbox_element.is(':checked')){
    file_container.show();
  }else{
    file_container.hide();
  }
}
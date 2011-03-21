// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function createSpinner() {
  return new Element('img', { src: root_url + 'images/ajax-loader.gif', 'class': 'spinner', 'height': '11', 'width': '11' });
}

$(function(){
  $("#project_start_date").datepicker();
  $("#project_end_date").datepicker();
  $("#sticky_start_date").datepicker();
  $("#sticky_end_date").datepicker();
  
  $("#ui-datepicker-div").hide();
  
  $(".pagination a").live("click", function() {
    // $(".pagination").html(createSpinner()); //.html("Page is loading...");
    // $.getScript(this.href);
    $.get(this.href, null, null, "script")
    return false;
  });
  
  // $("input[type='text']").change( function() {
  //   // check input ($(this).val()) for validity here
  // });
  
  $(".field_with_errors input, .field_with_errors_cleared input, .field_with_errors textarea, .field_with_errors_cleared textarea").change(function() {
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


// document.observe("dom:loaded", function() {
//   // the element in which we will observe all clicks and capture
//   // ones originating from pagination links
//   var container = $(document.body);
// 
//   if(container) {
//     // container.observe('click', function(e) {
//     //   var el = e.element();
//     //   if (el.match('.pagination a')) {
//     //     el.up('.pagination').insert(createSpinner());
//     //     var ajax_request = new Ajax.Request(el.href, { method: 'post', parameters: $('search-form').serialize()  + '&authenticity_token=' + encodeURIComponent(auth_token)  });
//     //     e.stop();
//     //   }
//     // });
//     
//     container.observe('change', function(e) {
//       var el = e.element();
//       if (el.match('.field_with_errors input') || el.match('.field_with_errors_cleared input')
//         || el.match('.field_with_errors textarea') || el.match('.field_with_errors_cleared textarea')){
//         if(el.value != '' && el.value != null){
//           el.parentNode.removeClassName('field_with_errors');
//           el.parentNode.addClassName('field_with_errors_cleared');
//         }else{
//           el.parentNode.removeClassName('field_with_errors_cleared');
//           el.parentNode.addClassName('field_with_errors');
//         }
//       }
//     })
//   }
// });

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
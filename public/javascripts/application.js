// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

document.observe("dom:loaded", function() {
  // the element in which we will observe all clicks and capture
  // ones originating from pagination links
  var container = $(document.body);

  if(container) {
    // container.observe('click', function(e) {
    //   var el = e.element();
    //   if (el.match('.pagination a')) {
    //     el.up('.pagination').insert(createSpinner());
    //     var ajax_request = new Ajax.Request(el.href, { method: 'post', parameters: $('search-form').serialize()  + '&authenticity_token=' + encodeURIComponent(auth_token)  });
    //     e.stop();
    //   }
    // });
    
    container.observe('change', function(e) {
      var el = e.element();
      if (el.match('.field_with_errors input') || el.match('.field_with_errors_cleared input')
        || el.match('.field_with_errors textarea') || el.match('.field_with_errors_cleared textarea')){
        if(el.value != '' && el.value != null){
          el.parentNode.removeClassName('field_with_errors');
          el.parentNode.addClassName('field_with_errors_cleared');
        }else{
          el.parentNode.removeClassName('field_with_errors_cleared');
          el.parentNode.addClassName('field_with_errors');
        }
      }
    })
  }
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
// alert('relTarget type:' + relTarget.tagName + " - " + relTarget.innerHTML);
  while (relTarget && relTarget != handler) {
    relTarget = relTarget.parentNode;
  }
	return (relTarget != handler);
}

function hideOnMouseOut(elements){
  elements.each(function(element){
    var element = $(element);
    element.onmouseout = function(e, handler) {
      if (isTrueMouseOut(e||window.event, this)) this.hide();
    }
  });
}

function authorAssuranceCheck(){
  if(!$('publication_author_assurance').checked){
    alert('Please read and check the Author Assurance and Sign Off');
    return false;
  }
  if(!confirm('Submit publication for review? No more edits will be possible.')){
    return false;
  }
  return true;
}
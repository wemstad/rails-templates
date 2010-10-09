/**
 * Put the focus in the first form element on the page if there
 * is one.
 */
Event.observe(window, 'load', function() {
	forms = $$('form')
	
	if (null != forms) {
		forms[0].focusFirstElement();		
	}
});

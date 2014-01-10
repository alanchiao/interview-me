$(document).ready(function() {
	// Fix input element click problem
	// Prevent the popup from closing
	$('.dropdown-menu').click(function(e) {
		e.stopPropagation();
	});
});
//Javascript file relating to problem creation form manipulation

//For manipulation of form fields
var formFieldsEditor = function(){
	var that = Object.create(formFieldsEditor.prototype);

	// allow user to remove a field
	that.remove_fields = function(link){
		$(link).after("input[type=hidden]").value = "1";
		$(link).closest(".fields").hide();
	},

	// allow user to add a field
	that.add_fields = function(link, association, content){
		var new_id = new Date().getTime();

		//Give each field a unique id based on the time added
		var regexp = new RegExp("new_" + association, "g")
		$(link).parent().before(content.replace(regexp, new_id));
		var new_fields = $(link).parent().prev().find('.panel-body');


		$(link).parent().prev().find('.panel-heading a').attr('href','#collapse_' + new_id);
		new_fields.attr('id','collapse_' + new_id);
	}

	//prevent modification of object slots
	Object.freeze(that)
	return that;
}

var showFormError = function(text) {
	$('#form-error-content').empty().text(text);
	$('#form-error-content').parent().removeClass('hidden');
};

$(document).ready(function(){
	// Make sure on problem creation page
	if($('#code-form').length) {
		//code editor for skeleton
		editor_skeleton = getCodeMirrorFromTextArea('code-skeleton');

		//code editor for sample solution
		editor_solution = getCodeMirrorFromTextArea('sample-solution');

		// Part One: allow user to select the desired type of problem form
		$('select#problem_type').bind('change', function() {
	  		$('.problem-type-form').hide();
	  		$('.problem-type-form input').attr('disabled', true);

	  		var selection = $(this).val();
	  		$('#' + selection).show();
	  		$('#' + selection + ' input').attr('disabled', false);
	  	}).change();

		//Load either design or code problem depending on last one attempted to be made.
		if (sessionStorage.lastProblemType == "design")
			$('select#problem_type').val("design-form").change()

		//Store fact that last worked problem is design or code.
		$('#design-form .field').last().click(function(){
			sessionStorage.lastProblemType = "design";
		});

		$('#submit-code-problem').click(function(e) {
			$('#form-error-content').parent().addClass('hidden');
			if ($('#problem_title').val().trim().length === 0 || $('#problem_question').val().trim().length === 0) {
				showFormError("You must provide a title and problem statement.");
				e.preventDefault();
			} else {
				sessionStorage.lastProblemType = "code";
			}
		});


	  	//Part Two: Adding hints to code problems
	  	var hintStrs = [];

	  	$('#add-hint').click(function(){
	  		$('#code-hints').append('<li><input class="input-rounded col-sm-12 margin-bottom-10" type="text" placeholder="Hint content"></input></br></li>');
	  	});

	  	$('#add-hints').click(function(){
	  		sessionStorage.lastProblemType = "code";

	  		$('#code-hints li input').each(function(){
	  			var hint = $(this).val();
	  			hintStrs.push(hint);
	  		});

	  		//Server call to add all hints associated with problem.
	  		$.ajax({
				type: "POST",
				url: "/problems/" + problem['id'] + "/hints",
				dataType: "script",
				data: {'hints': JSON.stringify(hintStrs)}
	  		});
	  	});

	  	//Part Three: Adding tests to code problems
	  	$('#add-test').click(function(){
	  		//HTML for form for adding test.
	  		var testDiv = "";
	  		testDiv += '<li class="test" style="margin-top:10px;"><label> Test </label>';
	  		testDiv += '<input type="text" class="test-input input-rounded col-sm-12 margin-bottom-10" placeholder="Test input"></input></br>';
	  		testDiv += '<input type="text" class="test-expected input-rounded col-sm-12 margin-bottom-10" placeholder="Expected correct output"></br>';
	  		testDiv += '<ul class= "test-mistakes"></ul>';

	  		if (hints.length > 0){
		  		testDiv += '<button class="add-mistake">Add mistake</button></li>';
	  			$('#code-tests').append(testDiv);
		  		$('#code-tests').find(":last-child.add-mistake").click(function(){
		  			//HTML for form for adding mistake
			  		var mistakeDiv = "";
			  		mistakeDiv += '<li><label> Mistake </label>';
			  		mistakeDiv += '<select class="mistake-hint">';
		  			for (var i=0; i < hints.length; i++){
	  					mistakeDiv += '<option value=' + hints[i]['id'] + '>' + hints[i]['content'] + '</option>';
	  				}
			  		mistakeDiv += '</select>';
			  		mistakeDiv += '<input type="text" class="mistake-output" placeholder="Expected wrong output"></input>';

			  		$(this).prev().append(mistakeDiv);
			  	});
			}
			else {
	  			$('#code-tests').append(testDiv);
			}
	  	});

	  	$('#add-tests').click(function(){
	  		sessionStorage.lastProblemType = "code";

	  		var tests = [];
	  		$('#code-tests .test').each(function(){
	  			var input = $(this).children('.test-input').val();
	  			var expected = $(this).children('.test-expected').val();
	  			if (input.trim().length > 0 && expected.trim().length > 0 ) {
	  				var mistakes = [];
		  			if (hints.length > 0){
			  			$(this).find('.test-mistakes li').each(function(){
			  				var hintId = $(this).find('select').val();
			  				var mistakeOutput = $(this).find('input').val();
			  				var mistake = [hintId, mistakeOutput]
			  				mistakes.push(mistake);
			  			});
			  		}
		  			var test = [input, expected, mistakes];
		  			tests.push(test);
	  			}
	  		});

	  		if (tests.length === 0) {
	  			showFormError("Must have at least one test case.");
	  			return false;
	  		}

	  		//Server side call to add all tests associated with a problem.
	  		$.ajax({
				type: "POST",
				url: "/problems/" + problem['id'] + "/tests",
				dataType: "script",
				data: {'tests': JSON.stringify(tests)}
	  		});
	  	});
	}
});


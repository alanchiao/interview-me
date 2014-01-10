var editor;
var solution;

var hintsTemplate = HandlebarsTemplates['hints'];

// Specifies that the test given by testId passes
// Changes the box associated with the test to green, and shows input and correct output
var passTest = function(testId, input, output) {
	var container = $('#' + testId + '-display');
	container.find('.panel-heading').removeClass('failed-test').addClass('passed-test');
	container.find('i').removeClass('fa-square').removeClass('fa-times').addClass('fa-check');
	container.find('.panel-body')
						.empty()
						.append($('<p />').text('Input: ' + input))
						.append($('<p />').text('Correct output: ' + output));
};

// Specifies that the test given by testId fails due to incorrect output
// Changes the box associated with the test to red, and shows input, expected output, and user output
var failTest = function(testId, input, expected, actual) {
	var container = $('#' + testId + '-display');
	container.find('.panel-heading').removeClass('passed-test').addClass('failed-test');
	container.find('i').removeClass('fa-square').removeClass('fa-check').addClass('fa-times');
	container.find('.panel-body')
						.empty()
						.append($('<p />').text('Input: ' + input))
						.append($('<p />').text('Correct output: ' + expected))
						.append($('<p />').text('Your output: ' + actual));
};

// Specifies that the test given by testId fails due to an error
var failTestWithError = function(testId, error) {
	var container = $('#' + testId + '-display');
	container.find('.panel-heading').removeClass('passed-test').addClass('failed-test');
	container.find('i').removeClass('fa-square').removeClass('fa-check').addClass('fa-times');
	container.find('.panel-body')
						.empty()
						.append($('<p />').text(error));
};

// Adds a hint to an existing test case display
var addHint = function(testId, hint) {
	$('#' + testId + '-display .panel-body').append($('<p />').addClass('hint').text('Hint: ' + hint));
};

$(document).ready(function() {

	// Make sure that we are on a code problem page
	if ($('#code-problem').length) {

		var SAVE_INTERVAL = 5000;

		// Initialize the editor with default Python settings
		// Uses the CodeMirror library: http://codemirror.net/
		editor = getCodeMirrorFromTextArea('code-textarea');
		editor.setSize("100%", 400);

		solution = getCodeMirrorFromTextArea('solution-textarea', { readOnly: 'nocursor' });
		solution.setSize("100%", 400);

		// Set up autosave on a timer
		setInterval(function () {
			var text = editor.getValue();
			var problemID = $('#problem-id').data('problem-id');
			$.ajax({
				type: "POST",
				url: "/attempts/autosave",
				dataType: "JSON",
				data: { 'text': text, 'problemID': problemID }
			});
		}, SAVE_INTERVAL);

		// Set up collapsing test cases
		$('.panel-collapse').collapse({
			toggle: false
		});
	}
});

// Overview: when the "run code" button is clicked, run the user's code twice
// The first time, run it and print output to the "console"
// The second time, run it and check the results of the test cases
// Uses the Skulpt Python --> JS interpreter: http://www.skulpt.org/
$(document).on('click', '#run-code', function() {

	var currentTestId;
	var currentInput;
	var currentOutput;
	var currentExpectedOutput;
	var currentMistakes;

	var hintmap;
	var hints;
	var activeHints;


	var outputHandler = function(text) {
		if (text !== '\n') {
			$('#code-output').append(text + '\n');
		}
	};

	var testsHandler = function(text) {
		if (text !== '\n') {
			// This is a bit of a hack. Since Skulpt.js only gives us output as strings printed to
			// stdout, we check correctness by printing out (user_output == expected output)
			// We preface this by 'verify_output' or 'verify_mistake' just in case the user is printing True or False
			// in their code as well.
			if (text === 'verify_output_True') {
				passTest(currentTestId, currentInput, currentExpectedOutput);
			} else if (text === 'verify_output_False') {
				actualOutput = '';
				failTest(currentTestId, currentInput, currentExpectedOutput, currentOutput);
			} else if (text.substr(0, 14) === 'verify_output_') {
				// 14 is length of the string "verify_output_"
				currentOutput = text.substr(14);
			} else if (text.substr(0, 15) === 'verify_mistake_') {
				// 15 is length of the string "verify_mistake_"
				var remainder = text.substr(15);
				var mistakeId = remainder.substr(0, remainder.indexOf("_"));
				if (remainder === mistakeId + '_True') {
					var hintId = hintmap[mistakeId];
					addHint(currentTestId, hints[hintId].content);
					activeHints[hintId] = hints[hintId];
				}
			}
		}
	};

	// Because of the way Skulpt works, some things are less smooth:
	// In particular, Skulpt takes a Python program and gives the stdout output line by line
	// So we must print the test case assertion in Python, and inspect it with Javascript
	// We also print the user's output for feedback to the user.
	var runTest = function() {
		var program = editor.getValue() + '\n';
		program += 'output =  ' + currentInput + '\n';
		program += 'expected = ' + currentExpectedOutput + '\n';
		program += 'print "verify_output_" + str(output)\n';
		program += 'print "verify_output_" + str(output == expected)\n';

		currentMistakes.forEach(function(mistake) {
			program += 'print "verify_mistake_' + mistake.id + '_" + str(output == ' + mistake.wrong_output + ')\n';
		});
		callPythonInterpreter(program, testsHandler, function(e) {
			failTestWithError(currentTestId, e.toString());
		});
	};

	// Run the user-submitted code
	// Note that the only communication with the server is getting test cases; no code uploaded to server
	var run = function(tests) {
		var program = editor.getValue() + '\n';
		var testcases = tests.testcases;

		// Reset the active hints
		// Use an object to ensure uniqueness (so we don't display the same hint twice in the list)
		activeHints = {};

		// First, interpret the code as written with test cases added, to give the console output
		program += 'print "----- BEGIN TEST CASES -----"\n';
		testcases.forEach(function(testcase) {
			program += 'print ">>> ' + testcase.testcase.input + '"\n';
			program += 'print ' + testcase.testcase.input + '\n';
		});
		callPythonInterpreter(program, outputHandler, function(e) {
			outputHandler(e.toString());
		});

		// Then call each of the test cases
		testcases.forEach(function(testcase) {
			var testCode = testcase.testcase;
			currentTestId = testCode.id;
			currentInput = testCode.input;
			currentExpectedOutput = testCode.correct_output;
			currentMistakes = testcase.mistakes;
			runTest();
		});

		// Show the failed tests
		$('#output-tabs a[href="#test-output"]').tab('show');
		$('.failed-test').siblings('.panel-collapse').collapse('show');
		$('.passed-test').siblings('.panel-collapse').collapse('hide');

		// Show the hints in their own tab
		var hintsToShow = [];
		for (var k in activeHints) {
			hintsToShow.push(activeHints[k]);
		}
		$('#hint-output').html(hintsTemplate({ 'hints' : hintsToShow }));
	};

	// Get the test cases from the server via AJAX and run them
	var testPath = $('#code-problem').data('tests-url');
	$('#code-output').text('');
	$.get(testPath, function(data) {
		var tests = $.parseJSON(data);
		hintmap = tests.hintmap;
		hints = tests.hints;
		run(tests);
	});

});

// When clicking on solution, refresh the editor so CodeMirror works
$(document).on('click', '#author-solution-tab', function() {
	solution.refresh();
});

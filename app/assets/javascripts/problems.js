// Convert a textarea into a Codemirror editor, with default Python 2.x syntax properties
var getCodeMirrorFromTextArea = function(id, additionalOptions) {
	var options = {
		mode: {
			name: "python",
			version: 2,
			singleLineStringErrors: false
		},
		lineNumbers: true,
		indentUnit: 4,
		indentWithTabs: true,
		tabMode: "shift",
		matchBrackets: true
	};

	if (additionalOptions !== undefined) {
		$.extend(options, additionalOptions);
	}
	return CodeMirror.fromTextArea(document.getElementById(id), options);
};

// Read standard Python libraries for interpreter
var readPythonLib = function(x) {
    if (Sk.builtinFiles === undefined || Sk.builtinFiles["files"][x] === undefined) {
        throw "File not found: '" + x + "'";
    }
    return Sk.builtinFiles["files"][x];
};

// Call the Python interpreter with the text specified by program
// outputHandler is the callback that takes the output text of the program
// exceptionHandler is called with the Python error if a runtime error occurs
var callPythonInterpreter = function(program, outputHandler, exceptionHandler) {
	Sk.configure({ output : outputHandler,
		read: readPythonLib });
	try {
		Sk.importMainWithBody('<stdin>', false, program);
	} catch (exception) {
		exceptionHandler(exception);
	}
};

$(document).ready(function() {
	// Add appropriate classes for styling on the selected category
	$('.list-group-item').click( function () {
		$('.list-group-item').removeClass('active');
		$(this).addClass('active');

	});

	// Show the first category on page load
	$('.default').click();
});

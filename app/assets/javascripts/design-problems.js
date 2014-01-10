// Load a bunch of Handlebars templates

// For displaying the top comment only:
var topCommentTemplate = HandlebarsTemplates['top_comment'];

// For displaying additional comments with the header
var sortedCommentsTemplate = HandlebarsTemplates['sorted_comments'];

// For displaying additional comments without the header
var additionalCommentsTemplate = HandlebarsTemplates['append_comments'];

var paginateTemplate = HandlebarsTemplates['design_comments_paginate'];

var commentResp = {comments: [], topComment: {}};
var step = 5;
var head = 0; // the index in the comments array of the top of the list of comments
var tail = 0; // index + 1 (ie. the next comment to be displayed)

// Handle newlines in a comment by converting them to <br>
// http://stackoverflow.com/questions/12331077/does-handlebars-js-replace-newline-characters-with-br
Handlebars.registerHelper('breaklines', function(text) {
    text = Handlebars.Utils.escapeExpression(text);
    text = text.toString();
    text = text.replace(/(\r\n|\n|\r)/gm, '<br>');
    return new Handlebars.SafeString(text);
});

// Load the comments when first visiting the page
// This is part of the callback to the AJAX request that gets all comments; it compiles the handlebars
// templates and renders the comments
var loadComments = function() {
    var comments = commentResp.comments;
    var topComment = commentResp.top_comment;

    // If no comments AND logged in, display "be the first" message
    // If they're not logged in, there is already the "log in to join discussion message",
    // so don't show both.

    // Figure out if you're logged in by looking for the new comment textarea, which is only
    // sent down by the server if the user is logged in
    if (comments.length === 0 &&
        (topComment === undefined || topComment === null) &&
        $('#comments-new textarea').length) {

        $('#comments-list').html('<br /><strong>Be the first to start a discussion!</strong>');
    }

    $('#comments-list').empty();
    appendTopComment(topComment);

    // If we've loaded all comments (other than the top), don't try to load more.
    if (comments.length > tail) {
        appendComments(tail, tail + step, true);
    }
};

// Function to move back and forth on pages of comments
// If newer is true, displays a page of newer comments (appearing earlier in the array)
var paginateLoad = function(newer) {
    // If there is only one page, do nothing
    if (tail <= step && tail >= commentResp.comments.length) {
        return;
    }

    if (newer) {
        // Don't do anything if we're already on the newest page
        if (tail !== step) {
            var end = head;
            tail = end - step;
            appendComments(tail, end, false);
        }
    } else {
        appendComments(tail, tail + step, false);
    }
};

// Append to the top comment on the page the comment specified by the parameters
// Apply all relevant CSS
var appendTopComment = function(comment) {
    // Rails JSON response is sometimes null instead of undefined
    if (comment !== null && comment !== undefined) {
        $('#comments-list div.top').remove();
        $('#comments-list').append(topCommentTemplate(comment));
        // add class to style top comment
        $(".comment-box").first().addClass("top");
    }
};

// Append comments that are not the top comment
// Replaces the current non-top comments with the comments in between appendStart and appendEnd
// If first is true, also appends the "Recent comments" header
var appendComments = function(appendStart, appendEnd, first) {
    var comments = commentResp.comments;

    // Don't append more than what exists
    if (appendEnd > comments.length) {
        appendEnd = comments.length;
    }

    // If start >= end, we are done. There are no more things to add.
    if (appendStart < appendEnd) {
        template = first ? sortedCommentsTemplate : additionalCommentsTemplate;
        $('#comments-list div:not(.top)').remove();
        $('#comments-list').append(template({ 'comments' : comments.slice(appendStart, appendEnd) }));
        head = appendStart;
        tail = appendEnd;
        if (comments.length > step) {
            $('#comments-paginator').html(paginateTemplate({ start: head+1, end: tail, total: comments.length }));

            // Hide the "first" and "newer" links for the first page, and "last" and "older" for last page
            if (head === 0) {
                $('#first').hide();
                $('#newer').hide();
                $('#older').show();
                $('#last').show();
            } else if (tail === comments.length) {
                $('#first').show();
                $('#newer').show();
                $('#older').hide();
                $('#last').hide();
            } else {
                $('#first').show();
                $('#newer').show();
                $('#older').show();
                $('#last').show();
            }
        }
    }
};

// Handles the behavior of toggling CSS classes for upvotes and downvotes (coloring the icons)
$(document).on('click', '.vote', function(e) {
	e.preventDefault();
    var commentId = $(this).attr("data-comment-id");
    var icon = $('a[data-comment-id='+commentId+']');

    if($(this).find(".fa-thumbs-o-up").length > 0){
        if(!icon.find('i.fa-thumbs-o-down').hasClass("active")){
            icon.find('i.fa-thumbs-o-up').toggleClass("active");
        }
        else{
            icon.find('i.fa-thumbs-o-down').toggleClass("active");
            icon.find('i.fa-thumbs-o-up').toggleClass("active");

        }
    }
    else{
        if(!icon.find('i.fa-thumbs-o-up').hasClass("active")){
            icon.find('i.fa-thumbs-o-down').toggleClass("active");
        }
        else{
            icon.find('i.fa-thumbs-o-down').toggleClass("active");
            icon.find('i.fa-thumbs-o-up').toggleClass("active");
        }
    }

	var id = $(this).data("comment-id");
	var vote = $(this).data("vote");
	var value = (vote == 'upvote') ? 1 : -1;

    // Send the upvote/downvote to the server
	$.ajax({
		type: "POST",
		url: "/comments/" + id + "/vote",
		dataType: "script",
		data: { 'value': value }
    });
});

// Handle the pagination clicks for comments
$(document).on('click', '.paginate', function() {
    var id = $(this).attr('id');
    if (id === 'first') {
        appendComments(0, step, false);
    } else if (id === 'newer') {
        paginateLoad(true);
    } else if (id === 'older') {
        paginateLoad(false);
    } else if (id === 'last') {
        var lastStart = Math.floor((commentResp.comments.length - 1) / step) * step;
        appendComments(lastStart, lastStart+step, false);
    }
    $('html, body').animate({ scrollTop: $('#most-recent-header').offset().top });
});

$(document).ready(function() {

    if ($('#design-problem-container').length > 0) {
        var SAVE_INTERVAL = 10000;
        var commentsUrl = $('#comments-list').data('comments-url');

        // Get comments and load them into the JS variable, then load the comments onto the page
        $.get(commentsUrl, {}, function(response) {
            commentResp = response;
            if(commentResp.top_comment !== undefined) {
                loadComments();
            }
        }, "JSON");

        // Set up the timer for autosave
        setInterval(function () {
            var text = $('#design-input').val();
            var problemID = $('#problem-id').data('problem-id');
            $.ajax({
                type: "POST",
                url: "/attempts/autosave",
                dataType: "JSON",
                data: { 'text': text, 'problemID': problemID },
                success: function(data) {
                    $('#save-status').html('Saved');
                }
            });
        }, SAVE_INTERVAL);


        // On changes to the contents of the user's solution, mark not as saved
        $('#design-input').on('keyup keypress change', function () {
            $('#save-status').html('Not saved');
        });

        // Show/hide solutions with JQuery's slideup/down
        $('#design-solution-title').click( function (e) {
            e.preventDefault();
            var shown = $('#design-solution').data('shown');
            if(shown === 'true') {
                $('#design-solution').slideUp();
                $('#design-solution').data('shown', 'false');
                $('#design-solution-title').find('a').html("View Solution");
            } else {
                $('#design-solution').slideDown();
                $('#design-solution').data('shown', 'true');
                $('#design-solution-title').find('a').html("Hide Solution");
            }
        });

        $('#add-comment-button').click( function(e) {
            if (!$('#add-comment').val().trim().length) {
                e.preventDefault();
            }
        });
    }
});

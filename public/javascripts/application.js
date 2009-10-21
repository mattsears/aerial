/*------------------------------------
    Global Javascripts
    Aerial
    Version /  1.0
    Author / att Sears
    email / matt@mattsears.com
    website / www.mattsears.com
-------------------------------------*/

/* When page is loaded
----------------------------*/
$(document).ready(function() {
    externalLinks();
});

//
var Comment = {

    author: '',
    homepage: '',
    email: '',
    body: '',
    article: '',

    // Submit a new comment to the server via ajax
    submit: function(article_id) {

        this.author   = $("input#comment_author").val();
        this.homepage = $("input#comment_website").val();
        this.email    = $("input#comment_email").val();
        this.body     = $("textarea#comment_body").val();
        this.article  = article_id;

        // Make sure we have the required fields
        if (!this.valid()){
            return false;
        }

        // Append a new comment if post is successful
        if (this.post()){
           this.appendNew();
        }
    },

    // Post the comment back to the server
    post: function() {

        // Data posted to server
        var data = 'author='+ this.author + '&email=' + this.email + '&homepage=' + this.phone + '&body=' + this.body;
        var url = "/article/" + this.article + "/comments";

        $.ajax({
            type: "POST",
            url:  url,
            data: data
        });

        return true;
    },

    // Add a div for the new comment
    appendNew: function() {

        // Template for the new comment div
        var t = $.template(
           "<div class='comment'><h2>${author}<span>${date}</span></h2><p>${message}</p></div>"
        );

        // Append
        $("#comments").append( t , {
            author: this.author,
            homepage: this.homepage,
            message: this.body
        });
    },

    // Ensure all required fields are filled-in
    valid: function() {

        if (this.author == "") {
            $("#author_label").addClass("error");
            return false;
        }

        if (this.email == "") {
            $("#email_label").addClass("error");
            return false;
        }

        if (this.comment == "") {
            $("#comment_label").addClass("error");
            return false;
        }
        return true;
    },

}

// Make all 'external' links in a new window
function externalLinks() {
    if (!document.getElementsByTagName) return;
    var anchors = document.getElementsByTagName("a");
    for (var i = 0; i < anchors.length; i++) {
        var anchor = anchors[i];
        if (anchor.getAttribute("href") &&
            anchor.getAttribute("rel") == "external")
            anchor.target = "_blank";
    }
}

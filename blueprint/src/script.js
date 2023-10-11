// Fixes over https://github.com/plastex/plastex/blob/master/plasTeX/Renderers/HTML5/Themes/default/js/plastex.js

$(document).ready(function() {

    $("nav.toc").off("click", "span.expand-toc");

    $("nav.toc").on("click", "span.expand-toc",
    function() {
        $(this).siblings("ul").slideToggle('fast');

        if ($(this).html() == "▼") {
            $(this).html("▶");
            $(this).addClass("collapse");
        } else {
            $(this).html("▼");
            $(this).removeClass("collapse");
        };

    })
});
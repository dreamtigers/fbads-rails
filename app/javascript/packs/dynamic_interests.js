// $(document).ready ->
//     $("#interests_text").on "keyup", ->
//         $.ajax
//             url: "/update_interests"
//             type: "POST"
//             dataType: "script"
//             data:
//                 suggestion: $('#fb_ad[interests_text]').val()
//             error: (jqXHR, textStatus, errorThrown) ->
//                 console.log("AJAX Error: #{textStatus}")
//             success: (data, textStatus, jqXHR) ->
//                 console.log("Dynamic country select OK!")

// document.addEventListener('DOMContentLoaded', () => {

//     var req = new XMLHttpRequest();

//     var $interests_text = document.getElementById('fb_ad_interests_text');
//     $interests_text.addEventListener('keyup', function(e) {
//         var interests_text_val = $interests_text.value;
//         console.log(interests_text_val);

//         req.open("GET", '/update_interests?suggestion='+interests_text_val, true);
//         req.send(interests_text_val);

//         console.log(req);

//     });
// });

function fetch_suggestions() {
    const search_text = $('#interests_text').val();
    $.post(
        '/update_interests',
        { suggestion: search_text, authenticity_token: window._token },
        function (response) {
            const selected_ids = $('#fb_ad_interests').val();
            if ($('#fb_ad_interests').children().length > 0) {
                $('#fb_ad_interests > option').each(function () {
                    const option_id = $(this).val();
                    if (selected_ids === null || !selected_ids.includes(option_id)) $(this).remove();
                });
            }
            response.forEach(function (d) {
                if (selected_ids === null || !selected_ids.includes(d.id)) {
                    const option = document.createElement('option');
                    option.value = d.id;
                    option.textContent = d.name + " | " + word(d.audience_size) + " | " + d.id;
                    $('#fb_ad_interests').append(option);
                }
            });
            // $('#fb_ad_interests').selectpicker('refresh');
            $('#fb_ad_interests').change();
        },
        'json',
    );
}
function word (labelValue) {
    return Math.abs(Number(labelValue)) >= 1.0e+9
    ? Math.round(((Math.abs(Number(labelValue)) / 1.0e+9 ) + Number.EPSILON) * 100) / 100 + "B"
    : Math.abs(Number(labelValue)) >= 1.0e+6
    ? Math.round(((Math.abs(Number(labelValue)) / 1.0e+6 ) + Number.EPSILON) * 100) / 100 + "M"
    : Math.abs(Number(labelValue)) >= 1.0e+3
    ? Math.round(((Math.abs(Number(labelValue)) / 1.0e+3 ) + Number.EPSILON) * 100) / 100 + "K"
    : Math.abs(Number(labelValue));
}

// document.addEventListener('DOMContentLoaded', () => {
//     var $interests_text = document.getElementById('interests_text');
//     $interests_text.addEventListener('keyup', throttle(fetch_suggestions, 500));
// });

$(document).ready(function () {
    $('#interests_text').on('keyup', throttle(fetch_suggestions, 500));
});

// I don't want to use lodash just for this function.
// https://stackoverflow.com/a/27078401
function throttle (callback, limit) {
    var wait = false;                  // Initially, we're not waiting
    return function () {               // We return a throttled function
        if (!wait) {                   // If we're not waiting
            callback.call();           // Execute users function
            wait = true;               // Prevent future invocations
            setTimeout(function () {   // After a period of time
                wait = false;          // And allow future invocations
            }, limit);
        }
    }
}

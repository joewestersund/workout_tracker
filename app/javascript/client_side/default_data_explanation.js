// used in routes index

function ready()
{
    var msg = $('#default-data-explanation').text();

    $('#default-data-label').click(function(event){
        alert(msg);
        event.preventDefault(); // Prevent link from following its href
    });
}

$(document).on('turbolinks:load', ready)

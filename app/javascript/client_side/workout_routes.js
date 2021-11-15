
function ready()
{
    var route_data = $('#route-data').innerHTML;

    var data = jQuery.parseJSON(route_data);

    $('route-dropdown').change(function(event){
        var id = $('option:selected',this).attr('value');
        alert("id = " + id);
    });
}

$(document).on('turbolinks:load', ready)
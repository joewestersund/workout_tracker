
function ready()
{
    $('.select-and-redirect').change(function(event){
        var select_element = $(event.target);
        console.log(select_element);
        var prefix = select_element.data('prefix');
        var suffix = select_element.data('suffix');
        var id = select_element.val();
        window.location.href = prefix + id + suffix;
    });
}

$(document).on('turbolinks:load', ready)

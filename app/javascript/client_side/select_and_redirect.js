
function ready()
{
    $('#select-and-redirect').change(function(event){
        var prefix = $('#select-and-redirect').data('prefix');
        var suffix = $('#select-and-redirect').data('suffix');
        var id = $("#select-and-redirect option:selected").val();
        window.location.href = prefix + id + suffix;
    });
}

$(document).on('turbolinks:load', ready)

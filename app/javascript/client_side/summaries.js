function ready() {
    var m_data_types;
    const ID_PREFIX = "r"; //to make sure the keys for m_workout_types don't look like numbers, so order is preserved
    const SHORT_INPUT = "short-input";

    function clearDropdownOptions(dropdown_id) {
        var dropdown = $(dropdown_id);
        dropdown.html('');  // clear any existing selections
    }

    function setDropdownOptions(dropdown_id, options, include_blank=true){
        clearDropdownOptions(dropdown_id);
        var dropdown = $(dropdown_id);
        if (include_blank)
            dropdown.append($('<option/>'));
        $.each(options, function (index, opt) {
            dropdown.append($('<option/>', {
                value: opt,
                text : opt
            }));
        });
    }

    function setEvents() {
        $('#data_type_id').change(function(event){
            var dt_id = $('#data_type_id').val();
            var dt = m_data_types[ID_PREFIX + dt_id];

            setDropdownOptions('#summary_function', dt.summary_function_options, false);
        });
    }

    if ($("#summary-options-box").length) {
        const jsonText = $("#summary-options-JSON").text();
        const jsonData = JSON.parse(jsonText);

        //convert data_types to a hash, with the workout_type_id as the key
        m_data_types = jsonData.data_types.reduce(function (map, dt) {
            var data_type_id_str = ID_PREFIX + dt.id;
            map[data_type_id_str] = dt; //convert key to string so order of elements is preserved
            return map;
        }, {});

        setEvents();

        const urlParams = new URLSearchParams(window.location.search);
        const summary_function = urlParams.get('summary_function');
        // initial values of other input boxes like workout_type, route and data_type are handled on server side in view.

        if (summary_function != null) {
            $('#summary_function').val(summary_function);
        } else {
            $('#data_type_id').change();
        }
    }
}

$(document).on('turbolinks:load', ready)

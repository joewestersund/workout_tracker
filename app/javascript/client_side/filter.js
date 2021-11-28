function ready() {
    var m_workout_types;
    const ID_PREFIX = "r"; //to make sure the keys for m_workout_types don't look like numbers, so order is preserved
    const SHORT_INPUT = "short-input";

    function clearDropdownOptions(dropdown_id) {
        var dropdown = $(dropdown_id);
        dropdown.html('');  // clear any existing selections
    }

    function setDropdownOptions(dropdown_id, options){
        clearDropdownOptions(dropdown_id);
        var dropdown = $(dropdown_id);
        dropdown.append($('<option/>'));
        $.each(options, function (index, opt) {
            dropdown.append($('<option/>', {
                value: opt.id,
                text : opt.name
            }));
        });
    }

    function setDataTypeDetailsDropdown(data_type) {

    }

    function setEvents() {
        $('#workout_type_id').change(function(event){
            var wt_id = $(this).val();
            if (wt_id == "") {
                clearDropdownOptions('#route_id');
                clearDropdownOptions('#data_type_id');
            } else {
                var wt = m_workout_types[ID_PREFIX + wt_id];
                setDropdownOptions('#route_id', wt.routes);
                setDropdownOptions('#data_type_id', wt.data_types);
            }
        });

        $('#data_type_id').change(function(event){
            var wt_id = $('#workout_type_id').val();
            var wt = m_workout_types[ID_PREFIX + wt_id];
            var dt_id = $(this).val();
            if (dt_id == "") {
                clearDropdownOptions("#data_type_details");
            } else {
                var dt = wt[ID_PREFIX + dt_id];
                setDataTypeDetailsDropdown(dt);
            }
        });

        $('#show_filter').click(function(event) {
            $('.filter').toggleClass('hidden');
        });

        $('#clear_filter').click(function(event) {
            $('.filter input[type="number"]').attr('value', '');
            $('.filter input[type="text"]').attr('value', '');
            $('.filter select option').attr('selected', false); //deselect all options
            $('.filter select option:first').attr('selected', true); //select the first option
            $('.filter form').submit(); //submit the form with the new, blank values;
        });
    }

    if ($("#workout-filter-box").length) {
        const jsonText = $("#workout-filter-JSON").text();
        const jsonData = JSON.parse(jsonText);

        //convert templates to a hash, with the route ID as the key
        m_workout_types = jsonData.workout_types.reduce(function (map, wt) {
            var workout_type_id_str = ID_PREFIX + wt.id;
            map[workout_type_id_str] = wt; //convert key to string so order of elements is preserved
            return map;
        }, {});

        alert("got here 2");

        // populate dropdowns
        setDropdownOptions('#workout_type_id', m_workout_types);

        alert("got here 3");

        setEvents();

        alert("got here 4");

        // set value of dropdowns, if any
        const urlParams = new URLSearchParams(window.location.search);
        const workout_type_id = urlParams.get('workout_type_id');
        const route_id = urlParams.get('route_id');
        const dt_id = urlParams.get('data_type_id');

        if (workout_type_id != null)
            $('#workout_type_id').val(workout_type_id);
        if (route_id != null)
            $('#route_id').val(route_id);
        if (dt_id != null)
            $('#data_type_id').val(dt_id);
    }
}

$(document).on('turbolinks:load', ready)
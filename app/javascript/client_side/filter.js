function ready() {
    var m_workout_types;
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
                value: opt.id,
                text : opt.name
            }));
        });
    }

    function setDataTypeDetailsDropdown(data_type) {
        var operator_dropdown_id = "#operator";
        var options_dropdown_id = "#dropdown_option_id";
        var input = $("#comparison_value");
        input.val("");  // clear input value
        if (data_type == null) {
            clearDropdownOptions(operator_dropdown_id);
            clearDropdownOptions(options_dropdown_id);
            $(operator_dropdown_id).addClass('hidden');
            $(options_dropdown_id).addClass('hidden');
            input.addClass('hidden');
        } else if (data_type.field_type == "dropdown list") {
            setDropdownOptions(operator_dropdown_id, [{name:"="}], false);   // don't include blank option
            setDropdownOptions(options_dropdown_id, data_type.options);
            $(operator_dropdown_id).removeClass('hidden');
            $(options_dropdown_id).removeClass('hidden');
            input.addClass('hidden');
        } else {
            if (data_type.field_type == "text") {
                setDropdownOptions(operator_dropdown_id, [{name:"LIKE"}, {name:"="}], false);
            } else {
                setDropdownOptions(operator_dropdown_id, [{name:"<"}, {name:"<="}, {name:"="}, {name:">="}, {name:">"}, {name:"!="}], false);
            }
            clearDropdownOptions(options_dropdown_id);
            $(operator_dropdown_id).removeClass('hidden');
            $(options_dropdown_id).addClass('hidden');
            input.removeClass('hidden');
            input.attr("pattern", data_type.input_pattern);
            input.attr("title", data_type.title_string);
        }
    }

    function setEvents() {
        $('#workout_type_id').change(function(event){
            var wt_id = $(this).val();
            if (wt_id == "") {
                clearDropdownOptions('#route_id');
                clearDropdownOptions('#data_type_id');
                $('#data_type_id').change();
            } else {
                var wt = m_workout_types[ID_PREFIX + wt_id];
                setDropdownOptions('#route_id', wt.routes);
                setDropdownOptions('#data_type_id', wt.data_types);
                $('#data_type_id').change();
            }
        });

        $('#data_type_id').change(function(event){
            var wt_id = $('#workout_type_id').val();
            var wt = m_workout_types[ID_PREFIX + wt_id];
            var dt_id = $(this).val();
            if (dt_id == null) {
                var dt = null;
            } else {
                var dt = wt.data_types_hash[ID_PREFIX + dt_id];
            }
            setDataTypeDetailsDropdown(dt);
        });

        $('#show_filter').click(function(event) {
            $('.filter').toggleClass('hidden');
        });

        $('#clear_filter').click(function(event) {
            var url = $("form:first").attr("action"); // the page name, with no params
            window.location.href = url;
        });
    }

    if ($("#workout-filter-box").length) {
        const jsonText = $("#workout-filter-JSON").text();
        const jsonData = JSON.parse(jsonText);

        //convert workout_types to a hash, with the workout_type_id as the key
        m_workout_types = jsonData.workout_types.reduce(function (map, wt) {
            var workout_type_id_str = ID_PREFIX + wt.id;
            map[workout_type_id_str] = wt; //convert key to string so order of elements is preserved
            return map;
        }, {});

        //convert data_types to a hash, with the data_type_id as the key
        $.each(m_workout_types, function (index, wt) {
            wt.data_types_hash = wt.data_types.reduce(function (map, dt){
                var data_type_id_str = ID_PREFIX + dt.id;
                map[data_type_id_str] = dt; //convert key to string so order of elements is preserved
                return map;
            }, {});
        });

        // populate dropdowns
        setDropdownOptions('#workout_type_id', m_workout_types);

        setEvents();

        // set initial value of dropdowns, if any
        const urlParams = new URLSearchParams(window.location.search);
        const workout_type_id = urlParams.get('workout_type_id');
        const route_id = urlParams.get('route_id');
        const dt_id = urlParams.get('data_type_id');
        const operator = urlParams.get('operator');
        const dropdown_option_id = urlParams.get('dropdown_option_id');
        const comparison_value = urlParams.get('comparison_value');
        // initial values of date input boxes like start_date, end_date, year and month are handled on server side in view.

        if (workout_type_id != null) {
            $('#workout_type_id').val(workout_type_id);
            $('#workout_type_id').change();
        }
        if (route_id != null) {
            $('#route_id').val(route_id);
        }
        if (dt_id != null){
            $('#data_type_id').val(dt_id);
            $('#data_type_id').change();
        }
        if (operator != null) {
            $('#operator').val(operator);
        }
        if (dropdown_option_id != null) {
            $('#dropdown_option_id').val(dropdown_option_id);
        }
        if (comparison_value != null) {
            $('#comparison_value').val(comparison_value);
        }
    }
}

$(document).on('turbolinks:load', ready)
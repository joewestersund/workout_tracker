
function ready() {
    var m_routeCount = 0;
    var m_workout_route_templates;
    var m_first_workout_route_template;
    var m_data_types;
    const ROUTES_LIST_ELEMENT = "#routes-list";
    const ROUTE_INFO_PREFIX = "route-info";
    const ROUTE_DETAILS_PREFIX = "route-details";
    const ROUTE_ID_PREFIX = "r"; //to make sure the keys for m_workout_route_templates don't look like numbers, so order is preserved
    const SHORT_INPUT = "short-input";

    function setEvents(){
        $(ROUTES_LIST_ELEMENT).on('change','.route-dropdown',function(event){
            var route_number = $(this).data("route-number");
            var route_id = $(this).val();
            var route_id_str = ROUTE_ID_PREFIX + route_id;
            var wr = m_workout_route_templates[route_id_str];  //keys are strings
            showRouteDetails(route_number, wr)
        });

        $('#add-route').click(function(event){
            event.preventDefault(); // Prevent link from following its href
            event.stopPropagation();
            appendRoute(m_first_workout_route_template); // add a new route to the page. For now, it'll be the first template
            return false;
        });

        $(ROUTES_LIST_ELEMENT).on('click','.delete-route',function(event){
            event.preventDefault(); // Prevent link from following its href
            event.stopPropagation();
            route_number = $(this).data("route-number");
            deleteRoute(route_number);
            return false;
        });
    }

    function showRouteDetails(route_number, workout_route){
        var route_number_string = "route" + route_number;
        var route_details_element = "#" + ROUTE_DETAILS_PREFIX + route_number;
        var dt;

        $(route_details_element).empty();

        workout_route.data_points.forEach((dp) => {
            dt = m_data_types[dp.data_type_id];

            $("<label/>", {
                "for": route_number_string + "data-type-id" + dp.data_type_id,
                html: dt.name
            }).appendTo( route_details_element );

            if (dt.field_type == "dropdown list") {
                var items = [];
                items.push( "<option value=''></option>" );  //include blank option in dropdown
                dt.options.forEach( (opt) => {
                    items.push( "<option value='" + opt.option_id + "'>" + opt.option_name + "</option>" );
                });
                $("<select/>", {
                    "name": "workout[route" + route_number + "[data_type" + dp.data_type_id + "[option_id]]",
                    id: route_number_string + "data-type-id" + dp.data_type_id,
                    html: items.join( "" )
                }).appendTo( route_details_element );

                // set the selected value in the dropdown
                $("#" + route_number_string + "data-type-id" + dp.data_type_id).val(dp.value);
            } else {
                var type = (dt.field_type == "numeric") ? "number" : "";
                var step = (dt.field_type == "numeric") ? "any" : "";
                var klass = (dt.field_type != "text" && dt.field_type != "dropdown list") ? SHORT_INPUT : "";
                $("<input/>", {
                    type: type,
                    step: step,
                    pattern: dt.input_pattern,
                    title: dt.title_string,
                    class: klass,
                    "name": "workout[route" + route_number + "[data_type" + dp.data_type_id + "[value]]",
                    id: route_number_string + "data-type-id" + dp.data_type_id,
                    value: dp.value
                }).appendTo( route_details_element );
            }
        });

        // show number of repetitions
        $("<label/>", {
            "for": route_number_string + "repetitions",
            html: "Repetitions"
        }).appendTo( route_details_element );

        $("<input/>", {
            type: "number",
            min: 1,
            class: SHORT_INPUT,
            "name": "workout[route" + route_number + "[repetitions]]",
            id: route_number_string + "repetitions",
            value: workout_route.repetitions
        }).appendTo( route_details_element );
    }

    function appendRoute(wr){
        var items = [];
        m_routeCount += 1;
        var route_number = m_routeCount;
        var route_name = "route" + route_number;
        var route_info_element = ROUTE_INFO_PREFIX + route_number;
        var route_details_element = ROUTE_DETAILS_PREFIX + route_number;

        // tell the server how many routes to look for in the form.
        // some may have been deleted, but this is the max number to look for.
        $("#workout_route_count").val(m_routeCount);

        $("<div/>", {
            "id": route_info_element,
            class: ROUTE_INFO_PREFIX,
        }).appendTo(ROUTES_LIST_ELEMENT);

        Object.keys(m_workout_route_templates).forEach( (key) => {
            var wrt = m_workout_route_templates[key];
            items.push( "<option value='" + wrt.route_id + "'>" + wrt.route_name + "</option>" );
        });

        $("<input/>", {
            type: "hidden",
            "name": "workout[route" + route_number + "[workout_route_id]]",
            value: wr.workout_route_id
        }).appendTo( "#" + route_info_element );

        $("<label/>", {
            "for": "route-dropdown" + route_number,
            html: "Route"
        }).appendTo( "#" + route_info_element );

        $("<select/>", {
            "class": "route-dropdown",
            "name": "workout[route" + route_number + "[route_id]]",
            "data-route-number": route_number,
            id: "route-dropdown" + route_number,
            html: items.join( "" ),
        }).appendTo( "#" + route_info_element );

        // set the selected value in the dropdown
        $("#route-dropdown" + route_number).val(wr.route_id.toString()); //key needs to be a string

        $("<a/>", {
            "class": "delete-route",
            "data-route-number": route_number,
            "data-turbolinks": false,
            href: "#",
            html: "Delete"
        }).appendTo( "#" + route_info_element );

        $("<div/>", {
            "id": route_details_element,
            class: ROUTE_DETAILS_PREFIX,
            html: "content goes here"
        }).appendTo("#" + route_info_element);

        showRouteDetails(route_number, wr);
    }

    function deleteRoute(routeNumber){
        $("#route-info" + routeNumber).remove();
    }

    if ($(ROUTES_LIST_ELEMENT).length) {
        const jsonText = $("#workout-form-JSON").text();
        const jsonData = JSON.parse(jsonText);

        const templates = jsonData.workout_route_templates;
        m_first_workout_route_template = templates[0];

        //convert templates to a hash, with the route ID as the key
        m_workout_route_templates = templates.reduce(function (map, wr) {
            var route_id_str = ROUTE_ID_PREFIX + wr.route_id;
            map[route_id_str] = wr; //convert key to string so order of elements is preserved
            return map;
        }, {});

        const workout_routes = jsonData.workout_routes;
        const data_types = jsonData.data_types;

        m_data_types = data_types.reduce(function (map, dt) {
            map[dt.id] = dt; //indexed by id, no need to preserve order
            return map;
        }, {});

        if (workout_routes.length == 0) {
            // this workout has no workout_routes yet. Add one route, the first template
            appendRoute(m_first_workout_route_template);
        } else {
            workout_routes.forEach((wr) => {
                // this workout has existing workout_routes. Show what's there.
                appendRoute(wr);
            });
        }

        setEvents();
    }
}

$(document).on('turbolinks:load', ready)
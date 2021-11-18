
function ready() {
    var m_routeCount = 0;
    var m_workout_route_templates;
    var m_first_workout_route_template;
    const ROUTES_LIST_ELEMENT = "#routes-list"
    const ROUTE_INFO_PREFIX = "route-info";
    const ROUTE_DETAILS_PREFIX = "route-details"

    function setEvents(){
        $(ROUTES_LIST_ELEMENT).on('change','.route-dropdown',function(event){
            var route_number = $(this).data("route-number");
            var route_id = $(this).val();
            var wr = m_workout_route_templates[String(route_id)];  //keys are strings
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

        alert("showing route details for " + workout_route.route_name);

        var route_number_string = "route" + route_number;
        var route_details_element = "#" + ROUTE_DETAILS_PREFIX + route_number;

        $(route_details_element).empty();

        workout_route.data_points.forEach((dp) => {
            $("<label/>", {
                "for": route_number_string + "data-type-id" + dp.data_type_id,
                html: dp.data_type_name
            }).appendTo( route_details_element );

            if (dp.is_dropdown) {
                var items = [];
                dp.options.forEach( (opt) => {
                    items.push( "<option value='" + opt.option_id + "'>" + opt.option_name + "</option>" );
                });
                $("<select/>", {
                    "name": "workout[routes" + route_number + "[data_type" + dp.data_type_id + "[option_id]]",
                    id: route_number_string + "data-type-id" + dp.data_type_id,
                    html: items.join( "" )
                }).appendTo( route_details_element );

                // set the selected value in the dropdown
                $("#" + route_number_string + "data-type-id" + dp.data_type_id).val(dp.value);

            } else {
                $("<input/>", {
                    "name": "workout[routes" + route_number + "[data_type" + dp.data_type_id + "[option_id]]",
                    id: route_number_string + "data-type-id" + dp.data_type_id,
                    value: dp.value
                }).appendTo( route_details_element );
            }
        });
    }

    function appendRoute(wr){
        var items = [];
        m_routeCount += 1;
        var route_number = m_routeCount;
        var route_name = "route" + route_number;
        var route_info_element = ROUTE_INFO_PREFIX + route_number;
        var route_details_element = ROUTE_DETAILS_PREFIX + route_number;

        $("<div/>", {
            "id": route_info_element,
            class: ROUTE_INFO_PREFIX,
        }).appendTo(ROUTES_LIST_ELEMENT);

        Object.keys(m_workout_route_templates).forEach( (key) => {
            var wrt = m_workout_route_templates[key];
            items.push( "<option value='" + wrt.route_id + "'>" + wrt.route_name + "</option>" );
        });

        $("<label/>", {
            "for": "route-dropdown" + route_number,
            html: "Route"
        }).appendTo( "#" + route_info_element );

        $("<select/>", {
            "class": "route-dropdown",
            "name": "workout[routes" + route_number + "[route_id]]",
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
        const jsonText = $("#JSON-data").text();
        const jsonData = JSON.parse(jsonText);

        const templates = jsonData.workout_route_templates;
        m_first_workout_route_template = templates[0];

        alert("mapping templates");

        //convert templates to a hash, with the route ID as the key
        m_workout_route_templates = templates.reduce(function (map, wr) {
            var route_id_str = String(wr.route_id);
            map[route_id_str] = wr; //convert key to string so order of elements is preserved
            return map;
        }, {});

        alert("mapped templates");

        const workout_routes = jsonData.workout_routes;

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
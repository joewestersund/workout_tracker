
function ready() {
    var m_routeCount = 0;
    var m_routes;
    var m_data_types;
    const ROUTES_LIST_ELEMENT = "#routes-list"
    const ROUTE_INFO_PREFIX = "route-info";
    const ROUTE_DETAILS_PREFIX = "route-details"

    function setEvents(){
        $(ROUTES_LIST_ELEMENT).on('change','.route-dropdown',function(event){
            var route_number = $(this).data("route-number");
            showRouteDetails(route_number)
        });

        $('#add-route').click(function(event){
            event.preventDefault(); // Prevent link from following its href
            event.stopPropagation();
            appendRoute();
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

    function showRouteDetails(route_number){
        var dropdown_element = "#route-dropdown" + route_number
        route_id = $(dropdown_element + " option:selected").val();

        var route_details_element = "#" + ROUTE_DETAILS_PREFIX + route_number;

        $(route_details_element).empty();

        $("<label/>", {
            "for": "route-data" + route_number,
            html: "Details for route id " + route_id
        }).appendTo( route_details_element );


    }

    function appendRoute(){
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

        $.each(m_routes, function(index, route) {
            items.push( "<option value='" + route.id + "'>" + route.name + "</option>" );
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
            html: items.join( "" )
        }).appendTo( "#" + route_info_element );

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

        showRouteDetails(route_number);
    }

    function deleteRoute(routeNumber){
        $("#route-info" + routeNumber).remove();
    }

    if ($(ROUTES_LIST_ELEMENT).length) {
        var url = $(ROUTES_LIST_ELEMENT).data("json-url");
        $.getJSON(url).done(function(json){
            // append the first spot for a route
            m_routes = json.routes;
            m_data_types = json.data_types;
            appendRoute();
            setEvents();
        });
    }
}

$(document).on('turbolinks:load', ready)
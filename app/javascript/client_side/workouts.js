
function ready() {
    var m_routeCount = 0;
    var m_routes;

    function setEvents(){
        $("#route-info").on('change','.route-dropdown',function(event){
            alert('triggered on change');
            //var id = $('option:selected', this).attr('value');
            //alert("id = " + id);
        });

        $('#add-route').click(function(event){
            event.preventDefault(); // Prevent link from following its href
            event.stopPropagation();
            appendRoute();
            return false;
        });

        $("#route-info").on('click','.delete-route',function(event){
            event.preventDefault(); // Prevent link from following its href
            event.stopPropagation();
            route_number = $(this).data("route-number");
            deleteRoute(route_number);
            return false;
        });
    }

    function appendRoute(){
        var items = [];
        m_routeCount += 1;
        var routeName = "route" + m_routeCount;
        $("<div/>", {
            "id": routeName,
            class: "field",
        }).appendTo("#route-info");

        $.each(m_routes, function(index, route) {
            items.push( "<option value='" + route.id + "'>" + route.name + "</option>" );
        });

        $("<label/>", {
            "for": "route-dropdown" + m_routeCount,
            html: "Route"
        }).appendTo( "#" + routeName );

        $("<select/>", {
            "class": "route-dropdown",
            "name": "workout[routes" + m_routeCount + "[route_id]]",
            html: items.join( "" )
        }).appendTo( "#" + routeName );

        $("<a/>", {
            "class": "delete-route",
            "data-route-number": m_routeCount,
            "data-turbolinks": false,
            href: "#",
            html: "Delete"
        }).appendTo( "#" + routeName );
    }

    function deleteRoute(routeNumber){
        $("#route" + routeNumber).remove();
    }

    if ($('#route-info').length) {
        var url = $('#route-info').data("json-url");
        $.getJSON(url).done(function(json){
            // append the first spot for a route
            m_routes = json.routes;
            appendRoute();
            setEvents();
        });
    }
}

$(document).on('turbolinks:load', ready)
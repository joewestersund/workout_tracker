//import * as d3 from "d3"
import * as Plot from "@observablehq/plot";

function ready() {
    var chart_present = $('#graph').length > 0;

    function load_chart() {
        $.ajax({
            type: 'GET',
            contentType: 'application/json; charset=utf-8',
            url: window.location,
            dataType: 'json',
            success: function(json_data) {
                //$('#graph').append("<div>" + JSON.stringify(json_data) + "</div>");  // DEBUG
                json_data.charts.forEach(function(c) {
                    draw_chart(c);
                });
            },
            error: function(result) {
                chart_error(result);
            }
        });
    }

    function draw_chart(data) {
        var svg;
        var cd = data.chart_data;
        var x_label = data.x_label;
        var y_label = data.y_label;

        if (cd.length == 0) {
            $('#graph').append("You haven't entered any workout data, or no data matches the filter above.");
        } else {
            if (data.chart_type == "bar"){
                if (data.stack_the_bars) {
                    // stack the bars for different routes, if multiple routes completed in the same day/week/month/year
                    svg = Plot.plot({
                        y: {
                            grid: true,
                            label: y_label
                        },
                        x: {
                            label: x_label,
                            tickRotate: "-30"
                        },
                        marginBottom: 70,
                        color: {
                            legend: true
                        },
                        marks: [
                            Plot.barY(cd, {x: "x_value", y: "y_value", fill: "series_name", title: "series_name"}),
                            Plot.ruleY([0])
                        ]
                    });
                } else {
                    // separate bars for each route, if multiple routes completed in the same day/week/month/year
                    svg = Plot.plot({
                        y: {
                            grid: true,
                            label: y_label
                        },
                        x: {
                            axis: null  // don't label each route on axis
                        },
                        fx: {
                            domain: cd.x_value,
                            label: x_label,
                            tickRotate: "-30"
                        },
                        color: {
                            legend: true
                        },
                        facet: {
                            data: cd,
                            x: "x_value",
                            marginBottom: 70
                        },
                        marks: [
                            Plot.barY(cd, {x: "series_name", y: "y_value", fill: "series_name", title: "series_name"}),
                            Plot.ruleY([0])
                        ]
                    })
                }
            } else {
                svg = Plot.plot({
                    y: {
                        grid: true,
                        label: y_label
                    },
                    x: {
                        label: x_label
                    },
                    color: {
                        legend: true
                    },
                    marks: [
                        Plot.dot(cd, {x: "x_value", y: "y_value", fill: "series_name", title: "label"}),
                        Plot.ruleY([0])
                    ]
                })
            }
            $('#graph').append(svg);
        }
    }

    function chart_error(result){
        console.log("chart error");
        $('.chart_error').remove();
        $('#graph').after("<div>" + result.statusText + "<p class='chart_error'>" + result.responseText + "</p></div>");
        console.log(result);
    }

    if (chart_present) {
        load_chart();
    }
}

$(document).on('turbolinks:load', ready);
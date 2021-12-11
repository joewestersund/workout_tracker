//import * as d3 from "d3"
//import { tip as d3tip } from "d3-v6-tip";
import * as Plot from "@observablehq/plot";

function ready() {
    var chart_present = $('#graph').length > 0;

    function load_chart() {
        $.ajax({
            type: 'GET',
            contentType: 'application/json; charset=utf-8',
            url: window.location,
            dataType: 'json',
            success: function(data) {
                draw_chart(data);
            },
            error: function(result) {
                chart_error(result);
            }
        });
    }

    function draw_chart(data) {
        var svg;
        if (data.chart_type == "bar"){
            if (data.stack_the_bars) {
                svg = Plot.plot({
                    y: {
                        grid: true
                    },
                    marks: [
                        Plot.barY(data.index, {x: data.x, y: data.y, fill: data.series_names}),
                        Plot.ruleY([0])
                    ]
                })
            } else {
                svg = Plot.plot({
                    y: {
                        grid: true
                    },
                    facet: {
                        data: data,
                        x: data.x
                    },
                    marks: [
                        Plot.barY(data.index, {x: data.series_names, y: data.y, fill: data.series_names}),
                        Plot.ruleY([0])
                    ]
                })
            }
        }

        $('#graph').append(svg);
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
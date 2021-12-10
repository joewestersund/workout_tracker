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
        alert("loading chart");
        var sales = [
            {units: 10, fruit: "fig", fill: 1},
            {units: 20, fruit: "date", fill: 2},
            {units: 40, fruit: "plum", fill: 2},
            {units: 30, fruit: "plum", fill: 3}
        ]
        $('#graph').append(Plot.dot(sales, {x: "units", y: "fruit", fill: "fill"}).plot());
        alert("plot loaded");
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
//import * as d3 from "d3"

//import { tip as d3tip } from "d3-v6-tip";

function ready() {
    var chart_present = $('svg').length > 0;

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

    function draw_chart(dataWithSeriesNames) {
        var data = dataWithSeriesNames.data;
        var margin = {
            top: 20,
            right: 70,
            bottom: 30,
            left: 70
        };
        var chart = d3.select('#graph')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom);
        var width = 960 - margin.left - margin.right;
        var height = 350 - margin.top - margin.bottom;
        //var color = d3.scaleOrdinal(d3.schemeCategory10);
        //color.domain = dataWithSeriesNames.seriesNames;
        //var parseDate = d3.timeParse('%Y-%m-%d');
        var i = 0;
        while (i < data.length) {
            var j = 0;
            while (j < data[i].length) {
                //data[i][j][0] = parseDate(data[i][j][0]);
                j++;
            }
            i++;
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
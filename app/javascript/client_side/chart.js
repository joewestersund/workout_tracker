import * as d3 from "d3"
import { tip as d3tip } from "d3-v6-tip";

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
        var width = 960 - margin.left - margin.right;
        var height = 350 - margin.top - margin.bottom;
        var color = d3.scaleOrdinal(d3.schemeCategory10);
        color.domain = dataWithSeriesNames.seriesNames;
        var parseDate = d3.timeParse('%Y-%m-%d');
        var i = 0;
        while (i < data.length) {
            var j = 0;
            while (j < data[i].length) {
                data[i][j][0] = parseDate(data[i][j][0]);
                j++;
            }
            i++;
        }
        dataWithSeriesNames.min_x = parseDate(dataWithSeriesNames.min_x);
        dataWithSeriesNames.max_x = parseDate(dataWithSeriesNames.max_x);
        var xScale = d3.scaleTime().range([margin.left, width + margin.left])
            .domain([dataWithSeriesNames.min_x, dataWithSeriesNames.max_x]);
        var yScale = d3.scaleLinear().range([height + margin.top, margin.top])
            .domain([dataWithSeriesNames.min_y - (dataWithSeriesNames.max_y - dataWithSeriesNames.min_y) * 0.05, dataWithSeriesNames.max_y]);
        //var xAxis = d3.svg.axis().scale(xScale).orient('bottom');
        //var xAxis = d3.axisBottom(xScale);
        var xAxis = d3.select(".axis").call(d3.axisBottom(xScale));
        var yAxis = d3.select(".axis").call(d3.axisLeft(yScale));
        //var yAxis = d3.axisLeft(yScale);
        var line = d3.line().curve(d3.curveLinear);
        var chart = d3.select('#graph')
            .attr('width', width + margin.left + margin.right)
            .attr('height', height + margin.top + margin.bottom);
        //chart.append('g').attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');
        //chart.append('g').attr('class', 'x axis').attr('transform', 'translate(0,' + (height + margin.top) + ')').call(xAxis);
        //chart.append('g').attr('class', 'y axis').attr('transform', 'translate(' + margin.left + ',0)').call(yAxis);
        var data_series = d3.select('#graph').selectAll('.data_series').data(data).enter().append('g').attr('class', 'data_series');
        data_series.append('path').attr('class', 'line').attr('d', function(d) {
            return line(d);
        }).style('stroke', function(d, i) {
            return color(dataWithSeriesNames.series_names[i]);
        });
        data_series.append('text').datum(function(d, i) {
            return {
                name: dataWithSeriesNames.series_names[i],
                value: d[0]
            };
        }).attr('transform', function(d) {
            return 'translate(' + xScale(d.value[0]) + ',' + yScale(d.value[1]) + ')';
        }).attr('x', 5).attr('dy', '.35em').text(function(d) {
            return d.name;
        }).style('fill', function(d, i) {
            return color(dataWithSeriesNames.series_names[i]);
        });
        var tip = d3tip().attr('class', 'd3-tip').html( function(d, i, seriesNum) {
            var date = (d[0].getMonth() + 1) + "/" + (d[0].getDate()) + "/" + (d[0].getFullYear());
            return "<span><div>" + date + "</div><div>" + d[1] + "</div><div>" + dataWithSeriesNames.series_names[seriesNum] + "</div></span>";
        });
        chart.call(tip);
        var circleSize = 4;
        var circleSizeHover = 6;
        var markers = data_series.selectAll('circle').data(function(d, i) {
            return d;
        }).enter().append('circle').attr('cx', function(d) {
            return xScale(d[0]);
        }).attr('cy', function(d) {
            return yScale(d[1]);
        }).attr('r', circleSize).attr('fill', function(d, i, seriesNum) {
            return color(dataWithSeriesNames.series_names[seriesNum]);
        }).on('mouseover', tip.show).on('mouseout', tip.hide);
        chart.append('line').style("stroke", "black").attr("x1", xScale(dataWithSeriesNames.min_x)).attr("y1", yScale(0)).attr("x2", xScale(dataWithSeriesNames.max_x)).attr("y2", yScale(0)).style("stroke-dasharray", "10, 10");
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
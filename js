 mapboxgl.accessToken = 'pk.eyJ1IjoiZW5qYWxvdCIsImEiOiJjaWhtdmxhNTIwb25zdHBsejk0NGdhODJhIn0.2-F2hS_oTZenAWc0BMf_uw';
 var map = new mapboxgl.Map({
     container: 'map', // container id
     style: 'mapbox://styles/mapbox/light-v9',
     center: [144, -20],
     zoom: 5,

 })
 map.addControl(new mapboxgl.NavigationControl());

 function mapboxProjection(lonlat) {
     var p = map.project(new mapboxgl.LngLat(lonlat[0], lonlat[1]))
     return [p.x, p.y];
 }

 var container = map.getCanvasContainer()
 var svg = d3.select(container).append("svg")
 var tooltipOffset = [-12, 24];
 var tooltip = d3.select("body")
     .append("div")
     .attr("class", "tooltip")

 var url = "data/qld_data.csv";
 d3.csv(url, function (err, data) {
     data.forEach(function (d) {
         d.y = +d.y;
         d.x = +d.x;
         d.coordinates = [d.x, d.y].join(",");
         d.coordinates = d.coordinates.split(",");
         d.Avg_Issue_2 = d3.format(".3n")(d.Avg_Issue_2)
     });

     var dots = svg.selectAll("circle.dot").data(data)
     var defaultFillColor = "#0082a3";

     dots.enter().append("circle").classed("dot", true)
         .attr("r", 1)
         .style({
             fill: defaultFillColor,
             "fill-opacity": 0.6,
             stroke: "#004d60",
             "stroke-width": 1
         })
         .transition().duration(1400)
         .attr("r", function (d) {
             return (d.Avg_Issue_2 * 40)
         })

     function render() {
         dots
             .each(function (d) {
                 d.proj = mapboxProjection(d.coordinates);
             })
             .attr("transform", function (d) {
                 return "translate(" + d.proj + ")"
             })
     }

     dots
         .on("mouseover", function (d, i) {
             d3.select(this).style({
                 fill: "#f04040"
             });
             document.getElementById('state-name').innerHTML = ": " + d.SED_NAME;
             document.getElementById('job-sec').innerHTML = " " + (d.Avg_Issue_2 * 100) + "%";
             document.getElementById('tooltip').innerHTML = ": " + (d.Avg_Issue_2 * 100) + "%";
         })
         .on("mouseout", function (d, i) {
             d3.select(this).style({
                 fill: defaultFillColor
             });
             tooltip
                 .style("display", "none");
         })

     map.on("viewreset", function () {
         render()
     })
     map.on("move", function () {
         render()
     })

     render()
 })

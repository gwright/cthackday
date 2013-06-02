d3 = window.d3

# Slurp up the town information. 
# city.json is an array of objects, one per town
Towns = window.towns = {}
d3.json "city.json", (error, towns) ->
  towns.forEach (t) ->
    Towns[t['Town']] = t

quantize = d3.scale.quantile()
  .domain([1000000, 5000000, 10000000, 20000000, 50000000, 100000000, 150000000, 200000000, 50000000])
  .range d3.range(9).map (i) ->
    "q#{i}-9"

town_info = (geo_properties) ->
  Towns[geo_properties["TOWN"]]

$(document).ready ->
 

  # Insert an SVG element into the DOM and a group
  svg = d3.select("#map").append("svg").attr("width", width).attr("height", height)
  g = svg.append("g")

  caption = d3.select('#caption')

  showCaption = (d, i) ->
    selection = d3.selectAll('path.selected')

    if d3.select(this).select('.selected').empty
      d3.select(this).classed('selected', true)
        .transition()
          .attr 'transform', (feature) -> zoom(feature, 2)
    else
      d3.select(this).classed('selected', false)
        .transition()
          .attr 'transform', (feature) -> zoom(feature, 1)

    selection.classed('selected', false)
      .transition()
        .attr 'transform', (feature) -> zoom(feature, 1)

    town = d.properties["TOWN"]
    info = Towns[town]
    name = [d.properties["TOWN"], info["Total Grants"]].join(', ')
    caption.html(name)


  # This is the default canvas size used by d3.geo
  width  = 960
  height = 500

  # The geographic center of Connecticut [longitude, latitude]
  ct_center = [-72.46, 41.36]
  offset = [width/2, height/2 + 75]

  # generate a projection function
  projection = d3.geo
    .mercator()           # use mercator https://en.wikipedia.org/wiki/Mercator_projection
    .center(ct_center)    # [longitude, latitude] go to <0,0>
    .translate(offset)    # translate <0,0> to the center of the default viewport
    .scale(17000)         # make the *world* fit in a 17000x17000 canvas

  # Create a path generator and configure with our projection function
  standard_path = d3.geo.path().projection(projection)

  # generate a projection function
  larger = d3.geo
    .mercator()           # use mercator https://en.wikipedia.org/wiki/Mercator_projection
    .center(ct_center)    # [longitude, latitude] go to <0,0>
    .translate(offset)    # translate <0,0> to the center of the default viewport
    .scale(25000)         # make the *world* fit in a 17000x17000 canvas
  larger_path = d3.geo.path().projection(larger)

  zoom = (feature, scale) ->
    [x, y] = standard_path.centroid(feature)
    "translate(#{x},#{y}) scale(#{scale}) translate(#{-x},#{-y})"


  # Get the topoJSON file describing the town outlines.
  d3.json "cttownstopo.json", (error, towns) ->
    # towns.objects.cttownsgeo is the object we want to convert to geoJSON
    # extract features property from the geoJSON data
    features = topojson.feature(towns, towns.objects.cttownsgeo).features

    # Add all the paths to the group
    g.selectAll("path")           # establish a group 
        .data(features)          # bind array of features to DOM elements
      .enter().append("path")     # append all entered elements as 'path' elements
        .attr("d", standard_path)        # constructe and apply path for each data element
        .on('click', showCaption)
        .attr('class', (d) ->
          grants = town_info(d.properties)["Total Grants"]
          tg = Number(grants.trim().replace(/,/g, ""))
          klass = quantize( tg )
          console.log( "#{d.properties["TOWN"]}: #{grants}, #{klass}" )
          klass
        )

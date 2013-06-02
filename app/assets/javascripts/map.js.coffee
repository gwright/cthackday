d3 = window.d3

# Slurp up the town information. 
# city.json is an array of objects, one per town
Towns = window.towns = {}
d3.json "city.json", (error, towns) ->
  towns.forEach (t) ->
    Towns[t['Town']] = t


$(document).ready ->
 
  caption = d3.select('#caption')

  showCaption = (d, i) ->
    d3.selectAll('path.selected').classed('selected', false).attr('d', path)
    d3.select(this).classed('selected', true).attr('d', larger_path)

    town = d.properties["TOWN"]
    info = Towns[town]
    name = [d.properties["TOWN"], info["Total Grants"]].join(', ')
    caption.html(name)

  # Insert an SVG element into the DOM and a group
  svg = d3.select("#map").append("svg").attr("width", width).attr("height", height)
  g = svg.append("g")

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
  path = d3.geo.path().projection(projection)

  # generate a projection function
  larger = d3.geo
    .mercator()           # use mercator https://en.wikipedia.org/wiki/Mercator_projection
    .center(ct_center)    # [longitude, latitude] go to <0,0>
    .translate(offset)    # translate <0,0> to the center of the default viewport
    .scale(25000)         # make the *world* fit in a 17000x17000 canvas
  larger_path = d3.geo.path().projection(larger)


  # Get the topoJSON file describing the town outlines.
  d3.json "cttownstopo.json", (error, towns) ->
    # towns.objects.cttownsgeo is the object we want to convert to geoJSON
    # extract features property from the geoJSON data
    features = topojson.feature(towns, towns.objects.cttownsgeo).features

    # Add all the paths to the group
    g.selectAll("path")           # establish a group 
         .data(features)          # bind array of features to DOM elements
      .enter().append("path")     # append all entered elements as 'path' elements
          .attr("d", path)        # constructe and apply path for each data element
          .on('click', showCaption)

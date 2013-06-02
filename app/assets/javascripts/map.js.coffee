d3 = window.d3

d3

#width = 960
#height = 500

#projection = d3.geo.mercator().center([0, 5]).scale(900).rotate([-180, 0])

####svg   = d3.select("body").append("svg").attr("width", width).attr("height", height)
#path  = d3.geo.path().projection(projection)
#g     = svg.append("g")

#hartford =  {"type":"FeatureCollection","properties":{"kind":"state","state":"CT"},"features":[
#    {"type":"Feature","properties":{"kind":"county","name":"Hartford","state":"CT"},"geometry":{"type":"MultiPolygon","coordinates":[[[[-73.0097,42.0390],[-72.8125,42.0390],[-72.8180,41.9952],[-72.7687,42.0007],[-72.7578,42.0336],[-72.5113,42.0336],[-72.4949,41.9459],[-72.5168,41.8583],[-72.4949,41.8583],[-72.5058,41.8090],[-72.4784,41.8145],[-72.4127,41.6009],[-72.4675,41.5845],[-72.5058,41.6447],[-72.5442,41.6447],[-72.7140,41.6283],[-72.7523,41.5790],[-72.8509,41.5680],[-72.8454,41.5461],[-72.9440,41.5571],[-72.9495,41.6447],[-72.9823,41.6392],[-73.0152,41.7981],[-72.9495,41.8090],[-72.9385,41.8966],[-72.8892,41.9733],[-73.0316,41.9678]]]]}}
#  ]}

  #d3.json "cttowns.json", (error, states) ->
  #g.selectAll("path").data(topojson.feature(hartford, hartford.properties).features).enter().append("path").attr "d", path



  #map = new SimpleMapD3
  #container: '.map'
  #datasource: {"type":"FeatureCollection","properties":{"kind":"state","state":"CT"},"features":[
  
$(document).ready ->
 
  caption = d3.select('#caption')

  showCaption = (d, i) ->
    town = d.properties["TOWN"]
    info = window.towns[town]
    name = [d.properties["TOWN"], info["Total Grants"]].join(', ')
    caption.html(name)
    #caption.html(d.properties.length)

  width = 960
  height = 500

  #projection = d3.geo.albersUsa()
  projection = d3.geo.mercator().center([-73,41.5]).scale(17000)
  svg = d3.select("#map").append("svg").attr("width", width).attr("height", height)
  path = d3.geo.path().projection(projection)
  g = svg.append("g")

  window.towns = {}
  d3.json "city.json", (error, cities) ->
    cities.forEach (c) ->
      window.towns[c['Town']] = c

  d3.json "cttownstopo.json", (error, towns) ->
    features = topojson.feature(towns, towns.objects.cttownsgeo).features
    g.selectAll("path").data(features).enter().append("path").attr("d", path).on('mouseover', showCaption).on('mousemove',showCaption).on('mouseout', -> caption.html('mouse over a town'))
#.on('mouseout', -> { caption.html("Mouse over") })
  #g.on('mouseover',showCaption).on('mouseout', -> { caption.html("Mouse over") })

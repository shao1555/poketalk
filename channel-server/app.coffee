REDIS_SERVER_HOST = 'localhost'
REDIS_SERVER_PORT = 6379
WEBSOCKET_SERVER_PORT = 8080

# Redis
redis = require 'redis'
redisClient = redis.createClient REDIS_SERVER_PORT, REDIS_SERVER_HOST

# WebSocket
webSocketServer = new require('ws').Server(port: WEBSOCKET_SERVER_PORT)

# URL
url = require 'url'
sessions = []

redisClient.psubscribe 'rooms.*'
redisClient.on 'pmessage', (channel, pattern, message) ->
  data = JSON.parse(message)
  location = data.location
  if data.location_visible == false
    delete data.location
  webSocketServer.clients.forEach (client) ->
    clientUrl = url.parse(client.upgradeReq.url, true)
    console.log(channel: pattern, pathname: clientUrl.pathname, query: clientUrl.query)
    if clientUrl.query['location'] && clientUrl.query['distance']
      latLng = clientUrl.query['location'].split(',')
      distance = Math.abs getDistanceFromLatLonInKm(latLng[0], latLng[1], location[0], location[1])
      client.send(JSON.stringify(data)) if distance < parseFloat(clientUrl.query['distance'])
    else
      client.send(JSON.stringify(data))

# 緯度経度の計算
getDistanceFromLatLonInKm = (lat1, lon1, lat2, lon2) ->
  # Radius of the earth in km
  R = 6371

  dLat = deg2rad(lat2 - lat1)
  dLon = deg2rad(lon2 - lon1)

  a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2)
  c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  R * c

deg2rad = (deg) ->
  deg * Math.PI / 180
  

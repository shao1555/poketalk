REDIS_SERVER_HOST = 'localhost'
REDIS_SERVER_PORT = 6379
WEBSOCKET_SERVER_PORT = 8080

# Redis
redis = require 'redis'
redisClient = redis.createClient REDIS_SERVER_PORT, REDIS_SERVER_HOST

# WebSocket
webSocketServer = new require('ws').Server(port: WEBSOCKET_SERVER_PORT)

sessions = []

#webSocketServer.on 'connection', (webSocket) ->

redisClient.subscribe 'rooms/5795861ab905fe642d399838'
redisClient.on 'message', (channel, message) ->
  webSocketServer.clients.forEach (client) ->
    client.send(message)

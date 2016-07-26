REDIS_SERVER_HOST = 'localhost'
REDIS_SERVER_PORT = 6379

# Redis
redis = require 'redis'
redis_client = redis.createClient REDIS_SERVER_PORT, REDIS_SERVER_HOST

# WebSocket
websocket = require 'websocket-server'
websocket_server = websocket.createServer()

redis_client.subscribe 'rooms/*'
redis_client.on 'message', (channel, message) ->
  websocket_server.broadcast(message)

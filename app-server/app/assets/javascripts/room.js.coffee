$(document).ready ->
  # 位置情報の準備
  $('#cover').show()
  if navigator.geolocation
    positionOptions =
      enableHighAccuracy: true
      timeout: 5000
      maximumAge: 0
    watchPositionHandler = null

    positionOnSuccess = (position) ->
      updatePosition position
      if $('#cover').css('display') == 'block'
        $('#cover').hide()
        $('#wait-for-location').show()
        setTimeout (->
          joinToRoom [
            longitude
            latitude
          ], true
          navigator.geolocation.clearWatch watchPositionHandler
          # TODO: 起動後も1分おきぐらいに位置を更新していきたい
          return
        ), 5000
      console.log position.coords

    positionOnError = (positionError) ->
      console.log positionError

    updatePosition = (position) ->
      latitude = position.coords.latitude
      longitude = position.coords.longitude
      $('#message_location_latitude').val latitude
      $('#message_location_longitude').val longitude

    watchPositionHandler = navigator.geolocation.watchPosition(positionOnSuccess, positionOnError, positionOptions)
    # TODO: 測位タイムアウトを実装 (10秒ぐらいで抜けさせる)

  joinToRoom = (location, sensor) ->
    roomId = $('#room').data('room-id')
    currentUserId = $('#room').data('current-user-id')
    template = $('#message-bubble-template')
    messages = $('#room .messages')

    insertMessageBubble = (messageData) ->
      message = template.clone()
      if messageData['user']['id'] == currentUserId
        message.find('.message').addClass 'message-sent'
      else
        message.find('.message').addClass 'message-received'
      message.find('.message-user-name').text messageData['user']['name']
      message.find('.message-body p.text').text messageData['body']
      message.find('.time').text messageData['created_at']
      messages.append message
      window.scrollTo 0, document.body.scrollHeight

    $.getJSON [
      '/messages.json?room_id='
      roomId
      '&location='
      location.join(',')
    ].join(''), (data) ->
      $('#cover').hide()
      $('#wait-for-location').hide()
      $('#room').show()
      data['messages'].forEach (messageData) ->
        insertMessageBubble messageData
    ws = new WebSocket('ws://127.0.0.1:8080/')
    ws.addEventListener 'message', (event) ->
      messageData = JSON.parse(event.data)
      insertMessageBubble messageData
      if messageData['body'] == $('#message_body').val()
        $('#message_body').val ''

#= require image_processor

POSITION_INITIALIZATION_SLEEPS = 3000

$(document).ready ->
  shareLocation = false
  currentUserId = null
  # 位置情報の準備
  $('#cover').show()
  if navigator.geolocation
    positionOptions =
      enableHighAccuracy: true
      timeout: 5000
      maximumAge: 0
    watchPositionHandler = null
    latitude = longitude = null

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
        ), POSITION_INITIALIZATION_SLEEPS

    positionOnError = (positionError) ->
      # TODO: エラーダイアログ

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
    distance = $('#room').data('distance')
    template = $('#message-bubble-template')
    messages = $('#room .messages')

    if currentUserId
      $('.message-composer').css('display', 'inline-flex')
    else
      $('.user-sign-up').css('display', 'inline-flex')

    insertMessageBubble = (messageData) ->
      $('.empty-view').hide();
      message = template.children().clone()
      if messageData['user']['id'] == currentUserId
        message.addClass 'message-sent'
      else
        message.addClass 'message-received'
      message.find('.message-user-name').text messageData['user']['name']
      message.find('.message-body p.text').text messageData['body']
      message.find('.time').text messageData['created_at']
      if messageData['image_url']
        image = $('<img>')
        image.attr('src', messageData['image_url'])
        message.find('.image-attachment').append(image)
      if messageData['location']
        mapLink = $('<a>')
        mapLink.attr('href', "/messages/#{messageData['id']}")
        mapLink.attr('target', '_blank')
        mapLink.text('位置情報あり')
        message.find('.map').append(mapLink)
      messages.append message
      window.scrollTo 0, document.body.scrollHeight


    webSocketReconnectHandler = null

    createWebSocketChannel = () ->
      ws = null
      $.getJSON [
        '/channel_sessions/new.json?room_id='
        roomId
        '&location='
        location.join(',')
        '&distance='
        distance
      ].join(''), (data) ->
        ws = new WebSocket(data['channel_session']['url'])
        ws.addEventListener 'open', (event) ->
          console.log 'connected'
          if webSocketReconnectHandler
            clearInterval(webSocketReconnectHandler)
            webSocketReconnectHandler = null
        ws.addEventListener 'message', (event) ->
          messageData = JSON.parse(event.data)
          insertMessageBubble messageData
          if messageData['body'] == $('#message_body').val()
            $('#message_body').val ''
            $('#image-picker-button').removeClass('btn-success')
            $('#image-picker-button').addClass('btn-default')
            $('#image-picker-button').prop('disabled', false)
            $('#message_image_url').val('')
            $('#location-button').removeClass('btn-success')
            $('#location-button').addClass('btn-default')
            $('#message_location_visible').val('false')
        ws.addEventListener 'close', (event) ->
          console.log 'disconnected'
          if !webSocketReconnectHandler
            webSocketReconnectHandler = setInterval(createWebSocketChannel, 5000)

    $.getJSON [
      '/messages.json?room_id='
      roomId
      '&location='
      location.join(',')
      '&distance='
      distance
    ].join(''), (data) ->
      $('#cover').hide()
      $('#wait-for-location').hide()
      $('#room').show()
      data['messages'].forEach (messageData) ->
        insertMessageBubble messageData
      createWebSocketChannel()

  $('#image-picker').on 'change', (event) ->
    if event.target.files[0]
      $('#image-picker-button i').removeClass('fa-file-picture-o')
      $('#image-picker-button i').addClass('fa-spinner')
      $('#image-picker-button i').addClass('fa-pulse')
      getResizedImageBlob event.target.files[0], (blob) ->
        # ref: http://dev.classmethod.jp/cloud/aws/s3-cors-upload/
        $.getJSON '/image_upload_tickets/new.json', (data) ->
          presigned_url = data['image_upload_ticket']['presigned_url']
          xhr = new XMLHttpRequest
          xhr.open 'put', presigned_url, true
          xhr.send blob
          xhr.onload = ->
            # TODO: アップロード成功/失敗の正しいハンドリング
            $('#image-picker-button').removeClass('btn-default')
            $('#image-picker-button').addClass('btn-success')

            $('#image-picker-button i').removeClass('fa-spinner')
            $('#image-picker-button i').removeClass('fa-pulse')
            $('#image-picker-button i').addClass('fa-file-picture-o')

            $('#message_image_url').val(data['image_upload_ticket']['resource_url'])
      # ファイルの多重アップロードを防止する
      $(this).val(null)
      $(this).prop('disabled', true)

  $('#image-picker-button').on 'click', (event) ->
    if $('#image-picker').prop('disabled')
      $('#image-picker-button').removeClass('btn-success')
      $('#image-picker-button').addClass('btn-default')
      $('#image-picker-button').prop('disabled', false)
      $('#message_image_url').val('')

  $('#location-button').on 'click', (event) ->
    if $('#message_location_visible').val() == 'false'
      $(this).removeClass('btn-default')
      $(this).addClass('btn-success')
      $('#message_location_visible').val('true')
    else
      $(this).removeClass('btn-success')
      $(this).addClass('btn-default')
      $('#message_location_visible').val('false')

  $('#new_user').on 'ajax:success', (event, data, status) ->
    currentUserId = data['user']['id']
    $('.message-composer').css('display', 'inline-flex')
    $('.user-sign-up').css('display', 'none')

  # $('#new_message').on 'ajax:'

# ref: https://egashira.jp/image-resize-before-upload
getResizedImageBlob = (file, callback) ->
  if !file.type || !file.type.match(/^image\/(png|jpeg|gif)$/)
    return
  img = new Image
  reader = new FileReader
  maxWidth = maxHeight = 800

  reader.onload = (e) ->
    data = e.target.result

    img.onload = ->
      iw = img.naturalWidth
      ih = img.naturalHeight
      width = iw
      height = ih
      orientation = undefined
      # JPEGの場合には、EXIFからOrientation（回転）情報を取得
      if data.split(',')[0].match('jpeg')
        orientation = getOrientation(data)
      # JPEG以外や、JPEGでもEXIFが無い場合などには、標準の値に設定
      orientation = orientation or 1
      # ９０度回転など、縦横が入れ替わる場合には事前に最大幅、高さを入れ替えておく
      if orientation > 4
        tmpMaxWidth = maxWidth
        maxWidth = maxHeight
        maxHeight = tmpMaxWidth
      if width > maxWidth or height > maxHeight
        ratio = width / maxWidth
        if ratio <= height / maxHeight
          ratio = height / maxHeight
        width = Math.floor(img.width / ratio)
        height = Math.floor(img.height / ratio)
      canvas = document.createElement('canvas')
      ctx = canvas.getContext('2d')
      ctx.save()
      # EXIFのOrientation情報からCanvasを回転させておく
      transformCoordinate canvas, width, height, orientation
      # iPhoneのサブサンプリング問題の回避
      # see http://d.hatena.ne.jp/shinichitomita/20120927/1348726674
      subsampled = detectSubsampling(img)
      if subsampled
        iw /= 2
        ih /= 2
      d = 1024
      # size of tiling canvas
      tmpCanvas = document.createElement('canvas')
      tmpCanvas.width = tmpCanvas.height = d
      tmpCtx = tmpCanvas.getContext('2d')
      vertSquashRatio = detectVerticalSquash(img, iw, ih)
      dw = Math.ceil(d * width / iw)
      dh = Math.ceil(d * height / ih / vertSquashRatio)
      sy = 0
      dy = 0
      while sy < ih
        sx = 0
        dx = 0
        while sx < iw
          tmpCtx.clearRect 0, 0, d, d
          tmpCtx.drawImage img, -sx, -sy
          # 何度もImageDataオブジェクトとCanvasの変換を行ってるけど、Orientation関連で仕方ない。本当はputImageDataであれば良いけどOrientation効かない
          imageData = tmpCtx.getImageData(0, 0, d, d)
          resampled = resample_hermite(imageData, d, d, dw, dh)
          ctx.drawImage resampled, 0, 0, dw, dh, dx, dy, dw, dh
          sx += d
          dx += dw
        sy += d
        dy += dh
      ctx.restore()
      tmpCanvas = tmpCtx = null
      dataURI = ctx.canvas.toDataURL('image/jpeg', .9)
      bin = atob(dataURI.split(',')[1])
      buffer = new Uint8Array(bin.length)
      i = 0
      while i < bin.length
        buffer[i] = bin.charCodeAt(i)
        i++
      blob = new Blob([ buffer.buffer ], type: file.type)
      callback.call(this, blob)

    img.src = data

  reader.readAsDataURL file

  # hermite filterかけてジャギーを削除する

  resample_hermite = (img, W, H, W2, H2) ->
    canvas = document.createElement('canvas')
    canvas.width = W2
    canvas.height = H2
    ctx = canvas.getContext('2d')
    img2 = ctx.createImageData(W2, H2)
    data = img.data
    data2 = img2.data
    ratio_w = W / W2
    ratio_h = H / H2
    ratio_w_half = Math.ceil(ratio_w / 2)
    ratio_h_half = Math.ceil(ratio_h / 2)
    j = 0
    while j < H2
      i = 0
      while i < W2
        x2 = (i + j * W2) * 4
        weight = 0
        weights = 0
        gx_r = 0
        gx_g = 0
        gx_b = 0
        gx_a = 0
        center_y = (j + 0.5) * ratio_h
        yy = Math.floor(j * ratio_h)
        while yy < (j + 1) * ratio_h
          dy = Math.abs(center_y - (yy + 0.5)) / ratio_h_half
          center_x = (i + 0.5) * ratio_w
          w0 = dy * dy
          xx = Math.floor(i * ratio_w)
          while xx < (i + 1) * ratio_w
            dx = Math.abs(center_x - (xx + 0.5)) / ratio_w_half
            w = Math.sqrt(w0 + dx * dx)
            if w >= -1 and w <= 1
              weight = 2 * w * w * w - (3 * w * w) + 1
              if weight > 0
                dx = 4 * (xx + yy * W)
                gx_r += weight * data[dx]
                gx_g += weight * data[dx + 1]
                gx_b += weight * data[dx + 2]
                gx_a += weight * data[dx + 3]
                weights += weight
            xx++
          yy++
        data2[x2] = gx_r / weights
        data2[x2 + 1] = gx_g / weights
        data2[x2 + 2] = gx_b / weights
        data2[x2 + 3] = gx_a / weights
        i++
      j++
    ctx.putImageData img2, 0, 0
    canvas

  # JPEGのEXIFからOrientationのみを取得する

  getOrientation = (imgDataURL) ->
    byteStringToOrientation = (img) ->
      `var count`
      head = 0
      orientation = undefined
      loop
        if img.charCodeAt(head) == 255 & img.charCodeAt(head + 1) == 218
          break
        if img.charCodeAt(head) == 255 & img.charCodeAt(head + 1) == 216
          head += 2
        else
          length = img.charCodeAt(head + 2) * 256 + img.charCodeAt(head + 3)
          endPoint = head + length + 2
          if img.charCodeAt(head) == 255 & img.charCodeAt(head + 1) == 225
            segment = img.slice(head, endPoint)
            bigEndian = segment.charCodeAt(10) == 77
            if bigEndian
              count = segment.charCodeAt(18) * 256 + segment.charCodeAt(19)
            else
              count = segment.charCodeAt(18) + segment.charCodeAt(19) * 256
            i = 0
            while i < count
              field = segment.slice(20 + 12 * i, 32 + 12 * i)
              if bigEndian and field.charCodeAt(1) == 18 or !bigEndian and field.charCodeAt(0) == 18
                orientation = if bigEndian then field.charCodeAt(9) else field.charCodeAt(8)
              i++
            break
          head = endPoint
        if head > img.length
          break
      orientation
    byteString = atob(imgDataURL.split(',')[1])
    orientaion = byteStringToOrientation(byteString)
    orientaion

  # iPhoneのサブサンプリングを検出

  detectSubsampling = (img) ->
    iw = img.naturalWidth
    ih = img.naturalHeight
    if iw * ih > 1024 * 1024
      canvas = document.createElement('canvas')
      canvas.width = canvas.height = 1
      ctx = canvas.getContext('2d')
      ctx.drawImage img, -iw + 1, 0
      ctx.getImageData(0, 0, 1, 1).data[3] == 0
    else
      false

  # iPhoneの縦画像でひしゃげて表示される問題の回避

  detectVerticalSquash = (img, iw, ih) ->
    canvas = document.createElement('canvas')
    canvas.width = 1
    canvas.height = ih
    ctx = canvas.getContext('2d')
    ctx.drawImage img, 0, 0
    data = ctx.getImageData(0, 0, 1, ih).data
    sy = 0
    ey = ih
    py = ih
    while py > sy
      alpha = data[(py - 1) * 4 + 3]
      if alpha == 0
        ey = py
      else
        sy = py
      py = ey + sy >> 1
    ratio = py / ih
    if ratio == 0 then 1 else ratio

  transformCoordinate = (canvas, width, height, orientation) ->
    if orientation > 4
      canvas.width = height
      canvas.height = width
    else
      canvas.width = width
      canvas.height = height
    ctx = canvas.getContext('2d')
    switch orientation
      when 2
  # horizontal flip
        ctx.translate width, 0
        ctx.scale -1, 1
      when 3
  # 180 rotate left
        ctx.translate width, height
        ctx.rotate Math.PI
      when 4
  # vertical flip
        ctx.translate 0, height
        ctx.scale 1, -1
      when 5
  # vertical flip + 90 rotate right
        ctx.rotate 0.5 * Math.PI
        ctx.scale 1, -1
      when 6
  # 90 rotate right
        ctx.rotate 0.5 * Math.PI
        ctx.translate 0, -height
      when 7
  # horizontal flip + 90 rotate right
        ctx.rotate 0.5 * Math.PI
        ctx.translate width, -height
        ctx.scale -1, 1
      when 8
  # 90 rotate left
        ctx.rotate -0.5 * Math.PI
        ctx.translate -width, 0
      else
        break
    return

  dataURLtoBlob = (dataurl) ->
    bin = atob(dataurl.split('base64,')[1])
    len = bin.length
    barr = new Uint8Array(len)
    i = 0
    while i < len
      barr[i] = bin.charCodeAt(i)
      i++
    new Blob([ barr ], type: 'image/jpeg')

window.getResizedImageBlob = getResizedImageBlob

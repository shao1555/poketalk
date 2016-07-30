if message
  json.id message.id.to_s
  json.user do
    json.partial! partial: 'users/user', locals: { user: message.user }
  end
  json.body message.body
  json.created_at message.created_at
  json.location message.location_visible ? message.location : nil
  json.image_url message.image_url
else
  json.null!
end

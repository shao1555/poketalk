json.message do
  json.partial! partial: 'messages/message', locals: { message: @message }
end

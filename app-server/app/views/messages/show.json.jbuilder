json.message do
  json.partial! partial: 'messages/message', locals: { message: @message, filter: true }
end

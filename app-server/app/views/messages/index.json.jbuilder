json.messages @messages.each do |message|
  json.partial! partial: 'messages/message', locals: { message: message, filter: true }
end

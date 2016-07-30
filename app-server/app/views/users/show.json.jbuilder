json.user do
  json.partial! partial: 'users/user', locals: { user: @user }
end

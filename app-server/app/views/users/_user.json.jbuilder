if user
  json.id user.id.to_s
  json.name user.name
else
  json.null!
end

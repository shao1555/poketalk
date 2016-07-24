# Poketalk App Server

## Features

- login
- rooms
  - public
  - valor (red)
  - instinct (yellow)
  - mystic (blue)
- join
- say
- subscribe

/login
/rooms
/rooms/1/

## $MESSAGE

```json
{
  "message": {
    "user": {
      "id": 1,
      "name": "john"
    },
    "location": [ 35.658581, 139.745433 ],
    "body": "すごいポケモンみつけたぞ",
    "image": "https://static.poketalk.info/images/1.png",
    "created_at": "2016-07-24T08:13:20.923Z"
  }
}
```

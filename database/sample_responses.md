# Example API Responses

## POST /auth/login
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "<jwt-token>",
    "user": {
      "id": 2,
      "name": "Jane Doe",
      "email": "jane@example.com",
      "subscription_status": "free",
      "plan_id": null
    }
  }
}
```

## GET /channels?page=1
```json
{
  "success": true,
  "message": "Channels fetched",
  "data": {
    "items": [
      {
        "id": 1,
        "name": "Sports Live 1",
        "logo_url": "https://...",
        "stream_url": "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
        "description": "Live sports highlights and commentary.",
        "is_premium": 0,
        "category_name": "Sports",
        "current_program": "Morning Sports Desk"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 6
    }
  }
}
```

## GET /epg?channel_id=1
```json
{
  "success": true,
  "message": "EPG fetched",
  "data": [
    {
      "id": 1,
      "channel_id": 1,
      "title": "Morning Sports Desk",
      "description": "Daily sports recap.",
      "start_time": "2026-03-18 08:00:00",
      "end_time": "2026-03-18 09:00:00"
    }
  ]
}
```

## POST /subscription/assign
```json
{
  "success": true,
  "message": "Subscription activated",
  "data": {
    "plan_id": 2,
    "status": "premium",
    "end_date": "2026-04-17 12:10:15"
  }
}
```

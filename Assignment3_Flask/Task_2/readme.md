Flow of the Files

index.html
    │
    │ POST
    ↓
Backend /submit
    │
    ↓
MongoDB






data.html
    │
    │ GET /data using fetch()
    ↓
Backend /data
    │
    ↓
MongoDB
    │
    ↓
JSON
    │
    ↓
data.html displays it


200 → Success
400 → Bad Request
404 → Not Found
500 → Server Error
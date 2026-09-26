                    YOUR COMPUTER
─────────────────────────────────────────────────

        EXPRESS SERVER
        localhost:3000
              │
              │
              ▼
       ┌───────────────┐
       │   index.html  │
       │               │
       │ [Call Flask]  │
       └───────┬───────┘
               │
               │ fetch("/api/backend-data")
               ▼
       ┌────────────────┐
       │    Express     │
       │     server.js  │
       └───────┬────────┘
               │
               │ axios.get()
               │
               ▼
       ┌────────────────┐
       │     Flask      │
       │    localhost   │
       │      :5000     │
       └───────┬────────┘
               │
               │ /api/hello
               ▼
       ┌────────────────┐
       │ JSON Response  │
       │                │
       │ "Hello from    │
       │  Flask!"       │
       └───────┬────────┘
               │
               ▼
            Express
               │
               ▼
            Browser
               │
               ▼
        Displays message
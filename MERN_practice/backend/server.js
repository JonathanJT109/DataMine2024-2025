require('dotenv').config()
const express = require("express")

// Express app
const app = express()

// Middleware
app.use((req, res, next) => {
  console.log(req.path, req.method)
  next()
})

// Routes
app.get('/', (req, res) => {
  res.json({ mssg: "Welcome to the app" })
})

// Listen to requests
app.listen(process.env.PORT, () => {
  console.log('Listening on port', process.env.PORT, '😊')
})


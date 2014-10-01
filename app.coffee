app = require('koa')()
router = require('koa-router')
serve = require('koa-static')

app.use serve('./public')
app.use router(app)

server = require('http').Server(app.callback())
io = require('socket.io')(server)

Crawler = require './crawler'
crawler = new Crawler
crawler.start()

io.on 'connection', (socket) ->
  console.log 'initialize', socket.id
  socket.emit 'init', crawler.contents

crawler.on 'update-feed', ({feedTitle, entries, feedUrl}) ->
  io.sockets.emit 'update-feed', {feedTitle, entries, feedUrl}

server.listen(3000)

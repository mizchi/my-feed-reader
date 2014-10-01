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

crawler.on 'update-feed', ({title, contents}) ->
  io.sockets.emit 'update-feed', {title, contents}

server.listen(3000)

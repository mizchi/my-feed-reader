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

co = require 'co'

wait = (ms) -> new Promise (done) ->
  setTimeout done, ms

io.on 'connection', (socket) ->
  console.log 'connect', socket.id, crawler.contents.feedList.length
  socket.emit 'init', {feedList: [], feedCount: crawler.contents.feedList.length}

  do co ->
    for feed in crawler.contents.feedList
      console.log 'update-feed', socket.id, feed.feedTitle
      io.sockets.emit 'update-feed', feed
      yield wait(150)

  running = false
  socket.on 'request-crawl', ->
    unless running
      running = true
      console.log 'start crawler'
      crawler.crawl().then -> running = false
    else
      console.log 'crawler is running'

crawler.on 'update-feed', ({feedTitle, entries, feedUrl}) ->
  io.sockets.emit 'update-feed', {feedTitle, entries, feedUrl}

server.listen(2345)
console.log 'start server', 2345

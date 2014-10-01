fs = require 'fs'
co = require 'co'
request = require 'request'
{parseString} = require 'xml2js'
FeedParser = require 'feedparser'

loadData = -> new Promise (done) ->
  opml = fs.readFileSync('export.xml').toString()
  parseString opml, (err, data) ->
    if err
      throw 'export.xml is not valid xml'
    done(data)

getFeedList = (opml) ->
  sum = []
  for i in opml.opml.body[0].outline[0].outline
    if i.outline?.length?
      sum.push (i.outline.map (f) -> f.$)...
    else
      sum.push i.$
  sum

startCrawler = (url, interval=10000) ->
  id = setInterval ->
    crawl url
  , interval
  ->
    clearInterval id

crawl = (url) -> new Promise (done) ->
  feeds = []
  request(url)
  .on 'response', (res) ->
    res.pipe new FeedParser()
      .on 'readable', ->
        while item = this.read()
          feeds.push item
      .on 'end', ->
        done(feeds)
      .on 'error', (res) ->
        console.log url, 'fetch failed'
        done([])
  .on 'error', (res) ->
    console.log url, 'fetch failed'
    done([])

wait = (ms) -> new Promise (done) ->
  setTimeout done, ms

{EventEmitter} = require 'events'

module.exports =
class Crawler extends EventEmitter
  constructor: ->
    @contents = {} # Map<title: String, Array<FeedContent>>

  start: ->
    do update = =>
      setTimeout => do co =>
        console.log '[fetch start]'
        data = yield loadData()
        for feedData in getFeedList data
          console.log 'fetching:', feedData.title
          feedContents = yield crawl feedData.xmlUrl
          @contents[feedData.title] = feedContents

          @emit 'update-feed',
            title: feedData.title
            contents: feedContents

        console.log '[fetch end]'
        update()
      , 300 * 1000

fs = require 'fs'
co = require 'co'
_  = require 'lodash'
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
    @contents =
      feedList: [] # {feedTitle, }[]

  appendFeed: ({feedTitle, entries}) ->
    index = _.findIndex @contents.feedList, (feed) => feed.feedTitle is feedTitle
    if index > -1
      @contents.feedList[index].entries = entries
    else
      @contents.feedList.push {feedTitle, entries}

  start: ->
    do co =>
      while true
        console.log '[fetch start]'
        data = yield loadData()
        for feed in getFeedList data
          console.log 'fetching:', feed.title
          entries = yield crawl feed.xmlUrl
          feedTitle = feed.title

          console.log '---f-f-f-f-f-', feedTitle, entries.length

          @appendFeed {feedTitle, entries}
          @emit 'update-feed', {feedTitle, entries}

        console.log '[fetch end]'
        console.log @contents

        yield wait(1000 * 60 * 12)

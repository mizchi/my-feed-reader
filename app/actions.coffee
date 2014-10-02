###########
## Store
###########

buildUnreadEntries = ->
  unreadFeedList = []

  for {feedTitle, entries, feedUrl} in store.feedList
    throw 'no feed url' unless feedUrl

    lastPubdate = parseInt localStorage.getItem 'reading-done:'+feedUrl
    entries =
      if lastPubdate
        entries.filter (e) ->
          d = e.pubdate ? e.pubDate ? e.date
          moment(d).unix() > lastPubdate
      else
        entries
    if entries.length > 0
      unreadFeedList.push {feedTitle, entries, feedUrl}

  app.update
    unreadFeedList:
      $set: unreadFeedList

module.exports = Actions =
  init: ({feedList, feedCount}) ->
    app.update
      feedList:
        $set: feedList
      feedCount:
        $set: feedCount
    buildUnreadEntries()

  updateTitle: ({feedTitle, entries, feedUrl}) ->
    index = _.findIndex store.feedList, (feed) => feed.feedTitle is feedTitle

    query = null
    if index > -1
      store.feedList[index].entries = entries
      query = feedList: {}
      query.feedList[index] = entries: {$set: entries}
    else
      query = feedList: {$push: [{feedTitle, entries, feedUrl}]}

    app.update(query)
    buildUnreadEntries()

  selectNextFeed: ->
    feedList = if store.unread then store.unreadFeedList else store.feedList

    # touch storage when unread mode
    if store.unread
      feed = store.unreadFeedList[store.feedCursor]
      timestamps = feed.entries.map (f) -> moment(f.pubdate ? f.pubDate ? f.date).unix()
      maxTimestamp = Math.max timestamps...
      localStorage.setItem 'reading-done:'+feed.feedUrl, maxTimestamp ? moment().unix()

    if feedList.length > store.feedCursor + 1
      console.log 'selectNextFeed'
      app.update
        feedCursor:
          $set: store.feedCursor + 1
        entryCursor:
          $set: 0
    else
      app.update
        feedCursor:
          $set: 0
        entryCursor:
          $set: 0

  selectPrevFeed: ->
    if store.feedCursor > 0
      console.log 'selectPrevFeed'
      app.update
        feedCursor:
          $set: store.feedCursor - 1
        entryCursor:
          $set: 0

  selectNextEntry: ->
    feed = (if store.unread then store.unreadFeedList else store.feedList)[store.feedCursor]

    if feed? and store.entryCursor < feed?.entries.length - 1
      console.log 'selectNextEntry'
      app.update
        entryCursor:
          $set: store.entryCursor + 1

  selectPrevEntry: ->
    if store.entryCursor > 0
      console.log 'selectPrevEntry'
      app.update
        entryCursor:
          $set: store.entryCursor - 1

  openSelectedEntry: ->
    feedList = (if store.unread then store.unreadFeedList else store.feedList)
    entry = feedList[store.feedCursor]?.entries[store.entryCursor]
    console.log 'open', entry.link

    a = document.createElement 'a'
    a.href = entry.link
    a.target = '_blank'

    clickEvent = document.createEvent('MouseEvents')
    if ua is 'chrome'
      clickEvent.initMouseEvent('click', true, true, window, 0, 0, 0, 0, false, false, false, false, 1, null)
    else
      clickEvent.initMouseEvent("click", true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null)
    a.dispatchEvent(clickEvent)

  toggleUnread: ->
    buildUnreadEntries()

    app.update
      unread:
        $set: !store.unread
      feedCursor:
        $set: 0
      entryCursor:
        $set: 0

    console.log 'toggle unread flag to:', store.unread

  requestCrawl: ->
    socket.emit 'request-crawl'

  toggleHelp: ->
    app.update
      showHelp:
        $set: !store.showHelp

  refresh: ->
    app.forceUpdate()

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

  store.unreadFeedList = unreadFeedList

module.exports = Actions =
  initData: (data) ->
    store.feedList = data.feedList
    buildUnreadEntries()

    app.update()

  updateTitle: ({feedTitle, entries, feedUrl}) ->
    index = _.findIndex store.feedList, (feed) => feed.feedTitle is feedTitle
    if index > -1
      store.feedList[index].entries = entries
    else
      store.feedList.push {feedTitle, entries, feedUrl}

    # window.store = _.cloneDeep store
    buf = store.feedList
    store.feedList = []
    app.update?()

    store.feedList = buf
    buildUnreadEntries()
    app.update?()

    app?.forceUpdate()

  selectNextFeed: ->
    feedList = if store.unread then store.unreadFeedList else store.feedList

    if store.unread
      feed = store.unreadFeedList[store.feedCursor]
      timestamps = feed.entries.map (f) -> moment(f.pubdate ? f.pubDate ? f.date).unix()
      maxTimestamp = Math.max timestamps...
      localStorage.setItem 'reading-done:'+feed.feedUrl, maxTimestamp ? moment().unix()

    if feedList.length > store.feedCursor + 1
      console.log 'selectNextFeed'
      store.feedCursor++
      store.entryCursor = 0
      app.update?()
    else
      store.feedCursor = 0
      store.entryCursor = 0
      app.update?()

  selectPrevFeed: ->
    if store.feedCursor > 0
      console.log 'selectPrevFeed'
      store.feedCursor--
      store.entryCursor = 0
      app.update?()

  selectNextEntry: ->
    feed = (if store.unread then store.unreadFeedList else store.feedList)[store.feedCursor]
    if store.entryCursor < feed.entries.length - 1
      console.log 'selectNextEntry'
      store.entryCursor++
      app.update?()

  selectPrevEntry: ->
    if store.entryCursor > 0
      console.log 'selectPrevEntry'
      store.entryCursor--
      app.update?()

  openSelectedEntry: ->
    feedList = (if store.unread then store.unreadFeedList else store.feedList)
    entry = feedList[store.feedCursor]?.entries[store.entryCursor]

    if ua is 'chrome'
      clickEvent = document.createEvent('MouseEvents')
      clickEvent.initMouseEvent('click', true, true, window, 0, 0, 0, 0, false, false, false, false, 1, null)
      console.log 'open', entry.link
      jQuery('<a>').attr('href', entry.link)[0].dispatchEvent(clickEvent)
    else
      window.open entry.link

  toggleUnread: ->
    store.unread = !store.unread
    buildUnreadEntries()
    store.feedCursor = 0
    store.entryCursor = 0
    app.update?()
    console.log 'toggle unread flag to:', store.unread

  requestCrawl: ->
    socket.emit 'request-crawl'

  toggleHelp: ->
    store.showHelp = !store.showHelp
    app.update?()

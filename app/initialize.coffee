## require
g = window ? global
g.React = require 'react'
Kup = require('react-kup')(React)
_ = require 'lodash'
g.moment = require 'moment'

###########
## Store
###########

window.store =
  name: 'reader'
  feedList: []
  unreadFeedList: []
  feedCursor: 0
  entryCursor: 0
  unread: true

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

window.Actions =
  initData: (data) ->
    store.feedList = data.feedList
    buildUnreadEntries()

    update?()

  updateTitle: ({feedTitle, entries, feedUrl}) ->
    index = _.findIndex store.feedList, (feed) => feed.feedTitle is feedTitle
    if index > -1
      store.feedList[index].entries = entries
    else
      store.feedList.push {feedTitle, entries, feedUrl}

    # window.store = _.cloneDeep store
    buf = store.feedList
    store.feedList = []
    update?()

    store.feedList = buf
    buildUnreadEntries()
    update?()

    app?.forceUpdate()

  selectNextFeed: ->
    if store.feedList.length > store.feedCursor + 1
      if store.unread
        feed = store.unreadFeedList[store.feedCursor]
        timestamps = feed.entries.map (f) -> moment(f.pubdate ? f.pubDate ? f.date).unix()
        maxTimestamp = Math.max timestamps...

        localStorage.setItem 'reading-done:'+feed.feedUrl, maxTimestamp ? moment().unix()

      console.log 'selectNextFeed'
      store.feedCursor++
      store.entryCursor = 0
      update?()

  selectPrevFeed: ->
    if store.feedCursor > 0
      console.log 'selectPrevFeed'
      store.feedCursor--
      store.entryCursor = 0
      update?()

  selectNextEntry: ->
    feed = (if store.unread then store.unreadFeedList else store.feedList)[store.feedCursor]
    if store.entryCursor < feed.entries.length - 1
      console.log 'selectNextEntry'
      store.entryCursor++
      update?()

  selectPrevEntry: ->
    if store.entryCursor > 0
      console.log 'selectPrevEntry'
      store.entryCursor--
      update?()

  openSelectedEntry: ->
    entry = store.feedList[store.feedCursor]?.entries[store.entryCursor]

    clickEvent = document.createEvent('MouseEvents')
    clickEvent.initMouseEvent('click', true, true, window, 0, 0, 0, 0, false, false, false, false, 1, null)
    console.log 'open', entry.link
    jQuery('<a>').attr('href', entry.link)[0].dispatchEvent(clickEvent)

  toggleUnread: ->
    store.unread = !store.unread
    buildUnreadEntries()
    store.feedCursor = 0
    store.entryCursor = 0
    update?()
    console.log 'toggle unread flag to:', store.unread

###########
## Component
###########

Header = React.createClass
  render: ->
    {name, unread} = @props
    Kup ($) ->
      $.div ->
        $.span "Reader: #{name}:" + (if unread then 'unread' else '')

Entry = React.createClass
  render: ->
    {title, summary, guid} = @props
    Kup ($) ->
      $.div key: title, ->
        $.h4 title
        # $.span dangerouslySetInnerHTML:{__html: summary}
        $.span summary


window.jQuery = require 'jquery'
EntryList = React.createClass
  render: ->
    {entries, entryCursor, feedTitle} = @props
    Kup ($) ->
      $.ul className: 'entry-list', ref: 'scrollParent', style: {height: 800, overflow: 'scroll', backgroundColor: 'linen', padding: 0}, ->
        if entryCursor > 0
          $.li '<<'+entryCursor
        for entry, index in entries[entryCursor..]
          selected = index is 0

          opts =
            className: 'entry'
            key: 'entry-'+index
            style:
              backgroundColor: if selected then 'yellow' else 'white'
              listStyleType: 'none'
              padding: 10
              maring: 0

          if selected
            opts.ref = 'selected'
            opts.className += ' selected'

          $.li opts, ->
            $.component Entry, entry

Feed = React.createClass
  render: ->
    {feed, entryCursor} = @props
    {feedTitle, entries} = feed

    Kup ($) ->
      $.div ->
        $.h2 feedTitle
        $.component EntryList, {entries, entryCursor, feedTitle}

FeedContainer = React.createClass
  render: ->
    {feed, entryCursor} = @props
    Kup ($) ->
      $.component Feed, {feed, entryCursor}

FeedList = React.createClass
  render: ->
    {feedList, feedCursor, entryCursor} = @props
    selectedFeed = feedList[feedCursor]

    Kup ($) ->
      $.div {className: 'container', style: {display: '-webkit-box'}}, ->
        $.div className: 'left-pane', style: {width: '30%'}, ->
          if feedCursor > 0
            $.span '<<'+feedCursor

          $.ul className: 'feed-list', ref: 'scrollParent', style: {height: 800}, ->

            for feed, index in feedList[feedCursor..]
              selected = index is 0
              opts =
                key: 'feed-'+index
                style:
                  color: if selected then 'red' else 'black'
              if selected
                opts.ref = 'selected'
                opts.className = 'selected-feed'

              $.p opts, feed.feedTitle+"(#{ feed.entries.length })"

        $.div style: {width: '70%'}, ->
          $.component FeedContainer, {feed: selectedFeed, entryCursor: entryCursor}

App = React.createClass
  getInitialState: -> store

  render: ->
    {name, feedList, feedCursor, entryCursor, unread} = @state
    if unread
      feedList = @state.unreadFeedList

    Kup ($) ->
      $.div className: 'container', style: {
        width: '100%'
        height: 700
        margin: '0 auto'
        padding: 0
        overflow: 'hidden'
      }, ->
        $.component Header, {name, unread}
        $.component FeedList, {feedList, feedCursor, entryCursor}

###########
## bootstrap
###########

startApp = ->
  window.update = ->
    app.setState store
  window.app = React.renderComponent (App {}), document.body

socket = io.connect()

keymap =
  a: 65
  s: 83
  j: 74
  k: 75
  o: 79
  '/': 191
  u: 85

window.addEventListener 'keydown', (ev) ->
  console.log ev.keyCode
  switch parseInt ev.keyCode
    when keymap.s then Actions.selectNextFeed()
    when keymap.a then Actions.selectPrevFeed()
    when keymap.j then Actions.selectNextEntry()
    when keymap.k then Actions.selectPrevEntry()
    when keymap.o then Actions.openSelectedEntry()
    when keymap.u then Actions.toggleUnread()

window.addEventListener 'load', ->
  socket.on 'init', (data) ->
    console.log('init with', data)
    Actions.initData data
    startApp()

  socket.on 'update-feed', ({feedTitle, entries, feedUrl}) ->
    console.log('update-feed', feedTitle)
    Actions.updateTitle {feedTitle, entries, feedUrl}

## require
g = window ? global
g.React = require 'react'
Kup = require('react-kup')(React)
_ = require 'lodash'
g.moment = require 'moment'


## Utilities

`
var getBrowser = function(){
    var ua = window.navigator.userAgent.toLowerCase();
    var ver = window.navigator.appVersion.toLowerCase();
    var name = 'unknown';

    if (ua.indexOf("msie") != -1){
        if (ver.indexOf("msie 6.") != -1){
            name = 'ie6';
        }else if (ver.indexOf("msie 7.") != -1){
            name = 'ie7';
        }else if (ver.indexOf("msie 8.") != -1){
            name = 'ie8';
        }else if (ver.indexOf("msie 9.") != -1){
            name = 'ie9';
        }else if (ver.indexOf("msie 10.") != -1){
            name = 'ie10';
        }else{
            name = 'ie';
        }
    }else if(ua.indexOf('trident/7') != -1){
        name = 'ie11';
    }else if (ua.indexOf('chrome') != -1){
        name = 'chrome';
    }else if (ua.indexOf('safari') != -1){
        name = 'safari';
    }else if (ua.indexOf('opera') != -1){
        name = 'opera';
    }else if (ua.indexOf('firefox') != -1){
        name = 'firefox';
    }
    return name;
};
`

ua = getBrowser()

###########
## Store
###########


window.store = null

initializeStore = ->
  window.store =
    showHelp: true
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

  refresh: ->
    buf = _.cloneDeep store
    initializeStore()
    update?()

    window.store = buf
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
    feedList = if store.unread then store.unreadFeedList else store.feedList

    if feedList.length > store.feedCursor + 1
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
    update?()
    console.log 'toggle unread flag to:', store.unread

  requestCrawl: ->
    socket.emit 'request-crawl'

  toggleHelp: ->
    store.showHelp = !store.showHelp
    update?()

###########
## Component
###########


Help = React.createClass
  render: ->
    Kup ($) =>
      $.div ->
        $.h3 'keybind:'
        $.hr()
        $.dl className: 'help', ->
          $.dt 'h'
          $.dd  'toggle help'

          $.dt 's'
          $.dd  'next feed'

          $.dt 'a'
          $.dd  'previous feed'

          $.dt 'j'
          $.dd  'next entry'

          $.dt 'k'
          $.dd  'previous entry'

          $.dt 'r'
          $.dd  'request crawling to server'

          $.dt 'u'
          $.dd  'toggle read/unread to show'

        $.hr()

Header = React.createClass
  onClickRefresh: ->
    localStorage.clear()
    location.reload()

  onClickHelp: ->
    Actions.toggleHelp()

  render: ->
    {name, unread, showHelp} = @props
    Kup ($) =>
      $.div =>
        $.span "Reader: #{name}:" + (if unread then 'unread' else '')
        $.span '|'
        $.button onClick: @onClickHelp, 'help'
        $.span '|'
        $.button onClick: @onClickRefresh, 'refresh'

        if showHelp
          $.component Help, {}

Entry = React.createClass
  render: ->
    {title, summary, guid} = @props
    Kup ($) ->
      $.div key: title, ->
        $.h4 title
        # $.span dangerouslySetInnerHTML:{__html: summary}
        # $.span summary

window.jQuery = require 'jquery'
EntryList = React.createClass
  render: ->
    {entries, entryCursor, feedTitle} = @props
    Kup ($) ->
      $.ul className: 'entry-list', ref: 'scrollParent', style: {height: 800, overflow: 'scroll', padding: 0}, ->
        if entryCursor > 0
          $.li '<<'+(entryCursor+1)+'/'+entries.length
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
        $.h2 {style: {margin: 0}}, feedTitle
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
      $.div className: 'rss-reader-container', ->
        $.div className: 'left-pane', style: {width: '25%'}, ->
          if feedCursor > 0
            $.span '<<'+(feedCursor+1)+'/'+feedList.length

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

        $.div style: {width: '75%'}, ->
          if selectedFeed?
            $.component FeedContainer, {feed: selectedFeed, entryCursor: entryCursor}

App = React.createClass
  getInitialState: -> store

  render: ->
    {name, feedList, feedCursor, entryCursor, unread, showHelp} = @state
    if unread
      feedList = @state.unreadFeedList

    Kup ($) ->
      $.div style: {
        width: '100%'
        height: 700
        margin: '0 auto'
        padding: 0
        overflow: 'hidden'
      }, ->
        $.component Header, {name, unread, showHelp}
        if feedList.length > 0
          $.component FeedList, {feedList, feedCursor, entryCursor}
        else
          $.div """
          Now loading...
          """

###########
## bootstrap
###########

startApp = ->
  initializeStore()
  window.update = ->
    app.setState store
  window.app = React.renderComponent (App {}), document.body

window.socket = io.connect()

keymap =
  a: 65
  s: 83
  j: 74
  k: 75
  o: 79
  '/': 191
  u: 85
  r: 82
  w: 87
  h: 72

window.addEventListener 'keydown', (ev) ->
  console.log ev.keyCode
  switch parseInt ev.keyCode
    when keymap.s then Actions.selectNextFeed()
    when keymap.a then Actions.selectPrevFeed()
    when keymap.j then Actions.selectNextEntry()
    when keymap.k then Actions.selectPrevEntry()
    when keymap.o then Actions.openSelectedEntry()
    when keymap.u then Actions.toggleUnread()
    when keymap.r then Actions.requestCrawl()
    when keymap.h then Actions.toggleHelp()
    # when keymap.w then Actions.refresh()

socket.on 'init', (data) ->
  console.log('init with', data)
  Actions.initData data
  Actions.toggleHelp()

socket.on 'update-feed', ({feedTitle, entries, feedUrl}) ->
  console.log('update-feed', feedTitle)
  Actions.updateTitle {feedTitle, entries, feedUrl}

window.addEventListener 'load', ->
  startApp()

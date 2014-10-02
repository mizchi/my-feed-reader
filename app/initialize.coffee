## require
g = window ? global
g.React = require 'react'
require 'react/addons'
g.moment = require 'moment'
g._ = require 'lodash'

## Utilities
{getBrowser} = require './utils'

window.ua = getBrowser()
window.store = null
window.app = null
window.socket = io.connect()
window.Actions = require './actions'

App = require './components/app'

startApp = ->
  initializeStore()
  window.app = React.renderComponent (App {}), document.body

initializeStore = ->
  window.store =
    showHelp: true
    name: 'reader'
    feedList: []
    unreadFeedList: []
    feedCursor: 0
    entryCursor: 0
    unread: true

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
  switch parseInt ev.keyCode
    when keymap.s then Actions.selectNextFeed()
    when keymap.a then Actions.selectPrevFeed()
    when keymap.j then Actions.selectNextEntry()
    when keymap.k then Actions.selectPrevEntry()
    when keymap.o then Actions.openSelectedEntry()
    when keymap.u then Actions.toggleUnread()
    when keymap.r then Actions.requestCrawl()
    when keymap.h then Actions.toggleHelp()

socket.on 'init', (data) ->
  console.log('init with', data)
  Actions.initData data
  Actions.toggleHelp()

socket.on 'update-feed', ({feedTitle, entries, feedUrl}) ->
  console.log('update-feed', feedTitle)
  Actions.updateTitle {feedTitle, entries, feedUrl}

window.addEventListener 'load', ->
  startApp()

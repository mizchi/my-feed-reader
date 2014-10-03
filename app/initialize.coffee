## require
g = window ? global
g.React = require 'react'
require 'react/addons'
g.moment = require 'moment'
g._ = require 'lodash'
g.jQuery = require 'jQuery'

## Utilities
{getBrowser} = require './utils'

window.ua = getBrowser()
window.store = null
window.app = null
window.socket = null
window.Actions = require './actions'

App = require './components/app'

initializeStore = ->
  window.store =
    feedCount: 1
    showHelp: true
    name: 'reader'
    feedList: []
    unreadFeedList: []
    feedCursor: 0
    entryCursor: 0
    unread: true

MouseTrap = require 'mousetrap'
setupKeyEvents = ->
  MouseTrap.bind 's', -> Actions.selectNextFeed()
  MouseTrap.bind 'a', -> Actions.selectPrevFeed()
  MouseTrap.bind 'j', -> Actions.selectNextEntry()
  MouseTrap.bind 'k', -> Actions.selectPrevEntry()
  MouseTrap.bind 'o', -> Actions.openSelectedEntry()
  MouseTrap.bind 'u', -> Actions.toggleUnread()
  MouseTrap.bind 'r', -> Actions.requestCrawl()
  MouseTrap.bind '?', -> Actions.toggleHelp()
  MouseTrap.bind 'l', -> Actions.refresh()

window.addEventListener 'load', ->
  initializeStore()
  setupKeyEvents()

  window.socket = io.connect()

  socket.on 'init', (data) ->
    # console.log('init with', data)
    Actions.init data
    Actions.toggleHelp()

  socket.on 'update-feed', ({feedTitle, entries, feedUrl}) ->
    # console.log('update-feed', feedTitle)
    Actions.updateTitle {feedTitle, entries, feedUrl}

  window.app = React.renderComponent (App {}), document.body

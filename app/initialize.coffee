## require
g = window ? global
g.React = require 'react'
Kup = require('react-kup')(React)
_ = require 'lodash'


###########
## Store
###########

window.store =
  name: 'reader'
  feedList: []
  feedCursor: 0
  entryCursor: 0

window.Actions =
  initData: (data) ->
    store.feedList = data.feedList
    update?()

  updateTitle: ({feedTitle, entries}) ->
    index = _.findIndex store.feedList, (feed) => feed.feedTitle is feedTitle
    if index > -1
      store.feedList[index].entries = entries
    else
      store.feedList.push {feedTitle, entries}
    update?()

  selectNextFeed: ->
    if store.feedList.length > store.feedCursor + 1
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
    console.log 'selectNextEntry'
    store.entryCursor++
    update?()

  selectPrevEntry: ->
    console.log 'selectPrevEntry'
    store.entryCursor--
    update?()

###########
## Component
###########

Header = React.createClass
  render: ->
    {name} = @props
    Kup ($) ->
      $.div "Reader: #{name}"

Entry = React.createClass
  render: ->
    {title, summary} = @props
    Kup ($) ->
      $.div ->
        $.h4 title
        $.span dangerouslySetInnerHTML:{__html: summary}

EntryList = React.createClass
  render: ->
    {entries, entryCursor} = @props
    Kup ($) ->
      $.ul ->
        for entry, index in entries
          $.li {
            style: {
              backgroundColor: if index is entryCursor then 'yellow' else 'white'
            }
          }, ->
            $.component Entry, entry

Feed = React.createClass
  render: ->
    {feed, entryCursor} = @props
    {feedTitle, entries} = feed

    Kup ($) ->
      $.div ->
        $.h2 feedTitle
        $.component EntryList, {entries, entryCursor}

FeedContainer = React.createClass
  render: ->
    {feed, entryCursor} = @props
    Kup ($) ->
      $.component Feed, {feed, entryCursor}

FeedList = React.createClass
  render: ->
    console.log 'feedList', feedCursor

    {feedList, feedCursor, entryCursor} = @props

    selectedFeed = feedList[feedCursor]

    Kup ($) ->
      $.div {className: 'container', style: {display: '-webkit-box'}}, ->
        $.div style: {width: '30%'}, ->
          $.ul ->
            for feed in feedList
              $.h2 {
                style: {
                  color: if feed.feedTitle is selectedFeed.feedTitle then 'red' else 'black'
                }
              }, feed.feedTitle

        $.div style: {width: '70%'}, ->
          $.component FeedContainer, {feed: selectedFeed, entryCursor: entryCursor}

App = React.createClass
  getInitialState: -> store

  render: ->
    console.log 'update!'

    {name, feedList, feedCursor, entryCursor} = @state
    Kup ($) ->
      $.div className: 'container', ->
        $.component Header, {name}
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

window.addEventListener 'keydown', (ev) ->
  console.log ev, ev.keyCode

  switch parseInt ev.keyCode
    when keymap.s then Actions.selectNextFeed()
    when keymap.a then Actions.selectPrevFeed()
    when keymap.j then Actions.selectNextEntry()
    when keymap.k then Actions.selectPrevEntry()

window.addEventListener 'load', ->
  socket.on 'init', (data) ->
    console.log('init with', data)
    Actions.initData data
    startApp()

  socket.on 'update-feed', ({feedTitle, entries}) ->
    console.log('update-feed', feedTitle)
    Actions.updateTitle {feedTitle, entries}

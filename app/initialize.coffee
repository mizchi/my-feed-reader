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
    store.feedList = Object.keys(data).map (key) -> title: key, contents: data[key]
    update()

  updateTitle: (title, data) ->
    feed = _.find store.feedList, (feed) -> feed.title is title

    store.feedList = Object.keys(data).map (key) -> title: key, contents: data[key]

    update()

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
        $.p summary

EntryList = React.createClass
  render: ->
    {entries} = @props

    Kup ($) ->
      $.ul ->
        for entry in entries
          $.li ->
            $.component Entry, entry

Feed = React.createClass
  render: ->
    {feedTitle, entries} = @props
    Kup ($) ->
      $.div ->
        $.h2 feedTitle
        $.component EntryList, {entries}

FeedContainer = React.createClass
  render: ->
    {feed} = @props
    Kup ($) ->
      $.component Feed, feed

FeedList = React.createClass
  render: ->
    {feedList} = @props

    feed = feedList[store.feedCursor]

    Kup ($) ->
      $.div {className: 'container', style: {display: '-webkit-box'}}, ->
        $.div style: {width: '30%'}, ->
          $.ul ->
            for feed in feedList
              $.h2 {}, feed.feedTitle

        $.div style: {width: '70%'}, ->
          $.component FeedContainer, {feed}

App = React.createClass
  getInitialState: -> store

  render: ->
    {name, feedList} = @state
    Kup ($) ->
      $.div className: 'container', ->
        $.component Header, {name}
        $.component FeedList, {feedList}

###########
## bootstrap
###########

startApp = ->
  window.app = React.renderComponent (App {}), document.body

window.update = ->
  app.setState store

socket = io.connect()
window.addEventListener 'load', ->
  socket.on 'init', (data) ->
    console.log('init with', data)
    store.feedList = data.feedList
    startApp()

  socket.on 'update-feed', ({feedTitle, entries}) ->
    index = _.findIndex store.feedList, (feed) => feed.feedTitle is feedTitle
    if index > -1
      store.feedList[index].entries = entries
    else
      store.feedList.push {feedTitle, entries}

Kup = require('react-kup')(React)

Header = require './header'

Entry = React.createClass
  render: ->
    {title, summary, guid, link} = @props
    Kup ($) ->
      $.div key: title, ->
        $.h4 title
        $.a href: link, ->
          $.img src:"http://b.hatena.ne.jp/entry/image/#{link}",border:0

Feed = React.createClass
  render: ->
    {feed, entryCursor} = @props
    {feedTitle, entries} = feed

    Kup ($) ->
      $.div ->
        $.h2 {style: {margin: 0}}, feedTitle

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

module.exports = App = React.createClass
  getInitialState: -> store

  update: (query) ->
    if query
      window.store = React.addons.update store, query

    @setState store

  render: ->
    {feedList, feedCursor, entryCursor, unread, showHelp, feedCount} = @state
    loadedFeedCount = feedList.length
    selectedFeed = feedList[feedCursor]

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
        $.component Header, {name, unread, showHelp, feedCount, loadedFeedCount}
        if feedList.length > 0
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
                $.component Feed, {feed: selectedFeed, entryCursor}
        else
          $.div """
          Now loading...
          """

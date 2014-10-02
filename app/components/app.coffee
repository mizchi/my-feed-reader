Kup = require('react-kup')(React)

Header = require './header'

Entry = React.createClass
  render: ->
    {title, summary, guid} = @props
    Kup ($) ->
      $.div key: title, ->
        $.h4 title
        # $.span dangerouslySetInnerHTML:{__html: summary}
        # $.span summary

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

module.exports = App = React.createClass
  getInitialState: -> store

  update: (query) ->
    if query
      window.store = React.addons.update store, query

    @setState store

  render: ->
    {name, feedList, feedCursor, entryCursor, unread, showHelp, feedCount} = @state
    loadedFeedCount = feedList.length

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
          $.component FeedList, {feedList, feedCursor, entryCursor}
        else
          $.div """
          Now loading...
          """

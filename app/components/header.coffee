Kup = require('react-kup')(React)
Help = require './help'

module.exports = Header = React.createClass
  onClickRefresh: ->
    localStorage.clear()
    location.reload()

  onClickHelp: ->
    Actions.toggleHelp()

  render: ->
    {name, unread, showHelp, feedCount, loadedFeedCount} = @props
    Kup ($) =>
      $.div =>
        $.span "Reader: mode" + (if unread then 'unread' else 'read')
        $.span '|'
        if loadedFeedCount < feedCount
          $.span 'Loading...:'
          $.span loadedFeedCount + '/' + feedCount
        $.button onClick: @onClickHelp, 'help'
        $.span '|'
        $.button onClick: @onClickRefresh, 'refresh'
        $.span '|'
        if showHelp
          $.component Help, {}

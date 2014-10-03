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
      $.div sytle: {outline: '1px solid black'},=>
        $.span "mode:" + (if unread then 'unread' else 'read')
        if loadedFeedCount < feedCount
          $.span 'Loading...:'
          $.span loadedFeedCount + '/' + feedCount
        $.div ->
          $.button onClick: @onClickHelp, 'help'
          $.button onClick: @onClickRefresh, 'refresh'
        if showHelp
          $.component Help, {}

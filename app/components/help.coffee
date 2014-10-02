Kup = require('react-kup')(React)

module.exports = Help = React.createClass
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

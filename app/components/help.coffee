Kup = require('react-kup')(React)

module.exports = Help = React.createClass
  render: ->
    Kup ($) =>
      $.div ->
        $.h3 'keybind:'
        $.hr()
        $.dl className: 'help', ->
          [
            ['?', 'toggle help']
            ['s', 'next feed']
            ['a', 'previous feed']
            ['j', 'next entry']
            ['k', 'previous entry']
            ['r', 'request crawling to server']
            ['u', 'toggle read/unread mode']
          ].forEach ([key, content] ) ->
            $.dt key
            $.dd content
        $.hr()

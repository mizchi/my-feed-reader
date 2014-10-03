Kup = require('react-kup')(React)

Entry = React.createClass
  render: ->
    {title, summary, guid, link} = @props
    Kup ($) ->
      $.div key: title, ->
        $.h4 title
        $.a href: link, ->
          $.img src:"http://b.hatena.ne.jp/entry/image/#{link}",border:0

module.exports = Feed = React.createClass
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

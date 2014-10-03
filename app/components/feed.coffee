Kup = require('react-kup')(React)
ProgressBar = require './progress-bar'

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
        progress = (entryCursor+1)/entries.length
        $.component ProgressBar, {progress}

        $.ul className: 'entry-list', ref: 'scrollParent', style: {height: 800, overflow: 'scroll', padding: 0}, ->
          for entry, index in entries[entryCursor..]
            selected = index is 0

            opts =
              className: 'entry'
              key: 'entry-'+index
              style:
                backgroundColor: if selected then '#fdffaa' else 'white'
                listStyleType: 'none'
                padding: 10
                maring: 0

            if selected
              opts.ref = 'selected'
              opts.className += ' selected'

            $.li opts, ->
              $.component Entry, entry

Kup = require('react-kup')(React)

module.exports = ProgressBar = React.createClass
  render: ->
    {progress} = @props
    Kup ($) ->
      $.svg width: '100%', height: 20, ->
        $.rect width: '100%', height: 20, x: 0, y: 0, fill: 'white', stroke: 'linen', strokeWidth: 1
        $.rect width: (progress*100)+'%', height: 20, x: 0, y: 0, fill: 'linen'

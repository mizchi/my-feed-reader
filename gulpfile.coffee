gulp = require('gulp')
webpack = require('gulp-webpack')

config =
  output:
    filename: 'all.js'
  module:
    loaders: [
      { test: /\.coffee$/, loader: "coffee" }
    ]
  resolve:
    extensions: ["", ".web.coffee", ".web.js", ".coffee", ".js"]

gulp.task 'webpack', ->
  gulp.src('app/initialize.coffee')
    .pipe(webpack(config))
    .pipe(gulp.dest('public/'));

gulp.task 'watch', ['webpack'], ->
  gulp.watch 'app/**/*.coffee', ['webpack']

gulp.task 'default', ['webpack']

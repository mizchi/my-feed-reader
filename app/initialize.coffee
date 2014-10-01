console.log 'initialized', Date.now()

store = {}

socket = io.connect()
socket.on 'init', (data) ->
  console.log('init with', data)
  store = data

socket.on 'update-feed', (data) ->
  console.log('update-feed', data.title);
  store[data.title] = data.contents

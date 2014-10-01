# RSS Reader

Livedoor reader like rss reader.

![](http://i.gyazo.com/4cf1110d8f659802c4d9446e19e70493.png)

Download export.xml(opml) from your livedoor reader.

## Keybind

```
h : toggle help
s : next feed
a : previous feed
j : next entry
k : previous entry
r : request crawling to server
u : toggle read/unread to show
```

## Requirements

- node 0.11
- coffeescript HEAD (`npm install jashkenas/coffeescript -g`)

## Build and Run

```
$ npm install gulp -g
$ npm install
$ gulp
$ coffee --nodejs --harmony app.coffee
```

## LiCENSE

MIT

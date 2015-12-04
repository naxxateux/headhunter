app.filter 'toArray', ->
  (obj) ->
    unless obj instanceof Object
      return obj
    _.map obj, (val, key) ->
      Object.defineProperty val, '$key',
        __proto__: null
        value: key

fs = require 'fs-plus'
_  = require 'underscore-plus'

module.exports =
class Entries
  constructor: () ->
    @load()

  needSync: ->
    atom.config.get 'recent-finder.syncImmediately'

  add: (path) ->
    return unless fs.existsSync path
    limit = atom.config.get('recent-finder.max')
    data = @get()
    data.unshift path
    @set _.uniq(data).slice(0, limit)

  set: (data, sync=@needSync()) ->
    @_data = data
    @save() if sync

  clear: -> @set [], true

  get: (sync=@needSync()) ->
    @load() if sync
    @_data

  save: ->
    @_data = _.filter @_data, (e) -> fs.existsSync e
    localStorage['recent-finder'] = JSON.stringify @_data

  load: ->
    @_data =
      if localStorage['recent-finder']
        JSON.parse localStorage['recent-finder']
      else
        []

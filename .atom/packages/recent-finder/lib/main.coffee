{CompositeDisposable} = require 'atom'
fs = require 'fs-plus'
Entries = require './entries'

module.exports =
  entries: null
  config:
    max:
      type: 'integer'
      default: 50
      minimum: 1
      description: "max number of entries to remember"
    syncImmediately:
      type: 'boolean'
      default: true
      description: "If true, save recent entries to localStorage on every file open and always read etnries from localStorage. If you want to sync entries across multiple atom windows immediately, this option is for you."

  activate: (state) ->
    @entries = new Entries

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.workspace.onDidOpen (event) =>
      @entries.add event.item.getPath?()

    atom.commands.add 'atom-workspace',
      'recent-finder:toggle': => @getView().toggle @entries.get()
      'recent-finder:clear': => @entries.clear()
    #
  deactivate: ->
    if @view?
      @view.destroy()
      @view = null
    @entries.save()
    @entries = null
    @subscriptions.dispose()

  # I can't depend on serialize/desilialize since its per-project based.
  serialize: ->

  getView:  ->
    @view ?= new (require './view')

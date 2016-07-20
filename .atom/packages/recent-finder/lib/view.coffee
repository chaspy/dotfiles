path = require 'path'
pkgRoot = atom.packages.resolvePackagePath('fuzzy-finder')
FuzzyFinderView = require path.join(pkgRoot, 'lib', 'fuzzy-finder-view')

module.exports =
class View extends FuzzyFinderView
  toggle: (items) ->
    if @panel?.isVisible()
      @cancel()
    else
      @setItems items
      @show()

  getEmptyMessage: (itemCount) ->
    if itemCount is 0
      'No file opend recently'
    else
      super

  destroy: ->

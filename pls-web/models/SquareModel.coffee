root = exports ? this

class root.SquareModel extends Backbone.Model
  defaults:
    color: 'white'
    row: 0
    col: 0
    selected: false
    piece: null

  getSquareId: ->
    # this is coffeescript string interpolation
    return "#{@get('row')}_#{@get('col')}"
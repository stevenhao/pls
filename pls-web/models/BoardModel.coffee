root = exports ? this

class root.BoardModel extends Backbone.Model
  defaults:
    currentSquare: null
    selectedSquare: null
    squares: new Backbone.Collection

  getSquareAt: (row, col) ->
#    console.log('getting ' + row + ',' + col)
    _.first @get('squares').where(
      row: row
      col: col
    )
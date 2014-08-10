# exports in a way to make things global
# we are basically saying, if exports doesn't exist yet, root should be
# an object that contains this file
root = exports ? this

# we prepend classes with `root.` so that we are defining them in
# the root object, which is accessible in all other files that
# have the `root = exports ? this` line.
class root.BoardController
  initialize: ->
    @_setUpBoardModel()
    @_createBoardView()

  _createBoardView: =>
    @boardView = new root.BoardView
      model: @boardModel

    @boardView.render()
    $('.chess-board-container').html(@boardView.$el)

  _setUpBoardModel: =>
    @boardModel = new root.BoardModel
    squares = @boardModel.get('squares')
    for row in _.range(8)
      for col in _.range(8)
        color = if (row + col) % 2 is 1 then 'black' else 'white'
        square = new root.SquareModel
          row: row
          col: col
          color: color
        squares.add(square)

    @boardModel.on 'clickSquare', @_onClickSquare

  _onClickSquare: (squareModel) =>
    prevSelected = @boardModel.get('selectedSquare')
    if prevSelected?
      # we need to unselect the current square
      prevSelected.set('selected', false)
      @boardModel.unset('selectedSquare')

    unless squareModel is prevSelected
      @boardModel.set('selectedSquare', squareModel)
      squareModel.set('selected', true)

    # for now, add a white king
    squareModel.set('piece', 'wK')


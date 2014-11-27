root = exports ? this

class root.BoardView extends Backbone.View
  # having an parameter of the form {x, y} basically
  # does the same thing as x = x, y = y but x and y
  # are passed in as an object such as {x: blah1, y: blah2}
  initialize: ({@model}) ->
    @_buildBoard()

  _buildBoard: =>
    for row in _.range(8)
      rowEl = $ '<div/>',
        class: 'board-row'
        id: "row#{row}"
      for col in _.range(8)
        squareModel = @model.getSquareAt(row, col)

        squareView = new root.SquareView(
          model: squareModel
          boardModel: @model
        )
        squareView.render()
        rowEl.append(squareView.$el)
      @$el.append(rowEl)



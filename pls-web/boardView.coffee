root = exports ? this

class root.BoardView extends Backbone.View
  initialize: (options) ->
    console.log options

  render: ->
    @_buildBoard()

  _buildBoard: ->
    color = true
    for row in _.range(8)
      rowEl = $ '<div/>',
        class: 'row'
        id: "row#{row}"
      for col in _.range(8)
        color = if (row + col) % 2 is 1 then 'black' else 'white'
        squareView = new root.SquareView(
          row: row
          col: col
          color: color
          )
        squareView.render()
        rowEl.append(squareView.$el)
      @$el.append(rowEl)


class root.SquareView extends Backbone.View
  className: 'square'
  events:
    'click': '_onClick'

  initialize: (options) ->
    @row = options.row
    @col = options.col
    @color = options.color

  render: =>
    # console.log 'render'
    @$el.attr('id', "square#{@row},#{@col}")
    @$el.addClass(@color)

  _onClick: (e) =>
    console.log 'yo i clickd', @row, @col
root = exports ? this


class controller
  initialize: (options) ->
    @cursq = undefined

  # variables
  # cursq - selected square, null if none

  click: (sq) ->
    console.log 'yo i clickd', sq.row, ",",  sq.col
    if @cursq != undefined
      console.log 'cursq = ', @cursq
      @cursq.unselect()
    @cursq = sq
    @cursq.select()

class root.BoardView extends Backbone.View
  initialize: (options) ->
    @controller = new controller()
    console.log options

  render: ->
    @_buildBoard()

  _buildBoard: ->
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
          selected: 'notselected'
          parent: this
          )
        @curguy = squareView
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
    @selected = options.selected
    @parent = options.parent

  render: =>
    # console.log 'render'
    @$el.attr('id', "square#{@row}_#{@col}")
    @$el.addClass(@color)

  select: =>
    @$el.addClass('selected')

  unselect: =>
    @$el.removeClass('selected')

  _onClick: (e) =>
    @parent.controller.click this
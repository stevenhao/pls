root = exports ? this

class root.SquareView extends Backbone.View
  # putting @ in front makes it a property of the class, not an instance
  # this is like a static variable
  @mp:
    wK : 'http://chessboardjs.com/img/chesspieces/wikipedia/wK.png'
    bK : 'http://chessboardjs.com/img/chesspieces/wikipedia/bK.png'
    wQ : 'http://chessboardjs.com/img/chesspieces/wikipedia/wQ.png'
    bR : 'http://chessboardjs.com/img/chesspieces/wikipedia/bR.png'

  # this is a special Backbone.View property
  className: 'square'

  # this is a special backbone feature. it listens to events on the view
  events:
    'click': '_onClick'

  initialize: ({@model, @boardModel}) ->
    @model.on 'change:selected', @_onChangeSelected
    @model.on 'change:piece', @_onChangePiece

  render: =>
    @$el.attr('id', "square#{@model.getSquareId()}")
    @$el.addClass(@model.get('color'))

  _onChangeSelected: =>
    @$el.toggleClass('selected', @model.get('selected'))

  _onChangePiece: =>
    piece = @model.get('piece')
    if piece?
      img = $('<img>').attr('src', root.SquareView.mp[piece]).addClass('piece')
      @$el.html(img)
    else
      @$el.html('')

  _onClick: (e) =>
    @boardModel.trigger 'clickSquare', @model
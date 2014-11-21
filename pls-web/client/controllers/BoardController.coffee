# exports in a way to make things global
# we are basically saying, if exports doesn't exist yet, root should be
# an object that contains this file
root = exports ? this

# we prepend classes with `root.` so that we are defining them in
# the root object, which is accessible in all other files that
# have the `root = exports ? this` line.
class root.BoardController
  @next:
    'wK': 'wQ'
    'wQ': 'bK'
    'bK': 'bR'
    'bR': null
  initialize: ->
    @_setUpBoardModel()
    @_createBoardView()
    @addPiece = 'wK'
    @whoseTurn = 'w'
    @computer = {
      'w': 0
      'b': 1
    }

    $('.color-selector').on('click', @_onColorSelected)
    $('.go-button').on('click', @_compmove)
    $('.reset-button').on('click', @_reset)

  _createBoardView: =>
    @boardView = new root.BoardView
      model: @boardModel

    @boardView.render()
    $('.chess-board-container').html(@boardView.$el)

  _setUpBoardModel: =>
    @boardModel = new root.BoardModel
    squares = @boardModel.get('squares')
    squares.reset()
    for row in _.range(8)
      for col in _.range(8)
        color = if (row + col) % 2 is 1 then 'black' else 'white'
        square = new root.SquareModel
          row: row
          col: col
          color: color
        squares.add(square)
    @boardModel.on 'clickSquare', @_onClickSquare
    @boardModel.on 'move', @_onMove

  _onColorSelected: (evt) =>
    checkbox = $(evt.currentTarget)
    if checkbox.attr('checked')
      checkbox.removeAttr('checked')
    else
      checkbox.attr('checked', 'checked')

    @computer[checkbox.attr('name')] = checkbox.attr('checked')
    console.log("computer[#{checkbox.attr('name')}] = #{if checkbox.attr('checked') then true else false}")


  _deselect: (curSquare) =>
    @boardModel.unset('selectedSquare')
    curSquare.set('selected', false)

  _select: (curSquare) =>
    @boardModel.set('selectedSquare', curSquare)
    curSquare.set('selected', true)

  _move: (prvSquare, curSquare) =>
    Meteor.call('validMove', @whoseTurn, @boardModel, prvSquare, curSquare, 
      (err, data) =>
        if !data
          return
        prvPiece = prvSquare.get('piece')
        curSquare.set('piece', prvPiece)
        prvSquare.unset('piece')

        @boardModel.trigger('move')
      )

  _onClickSquare: (curSquare) =>
    if @addPiece
      curSquare.set('piece', @addPiece)
      @addPiece = root.BoardController.next[@addPiece]
      @_checkState()
    else
      prvSquare = @boardModel.get('selectedSquare')
      if prvSquare
        @_deselect(prvSquare)
        @_move(prvSquare, curSquare)
      else
        if curSquare.get('piece') and curSquare.get('piece').charAt(0) == @whoseTurn
          @_select(curSquare)

  _onMove: =>
    if @whoseTurn == 'w'
      @whoseTurn = 'b'
    else
      @whoseTurn = 'w'

    Meteor.call('isMate', @whoseTurn, @boardModel,
      (err, data) =>
        if data == 'checkmate'
          alert('Checkmate!')
        else if data == 'stalemate'
          alert('Stalemate!')
        else
          @_nextmove()
        )

  _compmove: =>
    Meteor.call('bestMove', @whoseTurn, @boardModel, 
      (err, data) =>
        if !data
          return
        frm = @boardModel.getSquareAt(data.frm.row, data.frm.col)
        to = @boardModel.getSquareAt(data.to.row, data.to.col)
        @_move(frm, to)
      )

  _reset: =>
    if @addPiece == 'wK'
      console.log('randomizing.')
      Meteor.call('randomBoard',
        (err, data) =>
          if data
            @boardModel.getSquareAt(data.K.row, data.K.col).set('piece', 'wK')
            @boardModel.getSquareAt(data.Q.row, data.Q.col).set('piece', 'wQ')
            @boardModel.getSquareAt(data.k.row, data.k.col).set('piece', 'bK')
            @boardModel.getSquareAt(data.r.row, data.r.col).set('piece', 'bR')
            @whoseTurn = 'w'
            @addPiece = null
            console.log('successful.')
            @_checkState()
        )
    else
      console.log('clearing.')
      @boardModel.get('squares').each (p) =>
        p.unset('piece')
      @addPiece = 'wK'
      @_checkState()

  _checkState: =>
    if @addPiece == 'wK'
      $('.reset-button').attr('value', 'Random!')
    else 
      $('.reset-button').attr('value', 'Clear!')

    if !@addPiece
      @_nextmove()

  _nextmove: =>
    if @computer[@whoseTurn]
      @_compmove()
    else
      console.log('your move!')
      Meteor.call('isInCheck', @whoseTurn, @boardModel,
        (err, data) =>
          if data
            console.log('check!')
        )
      Meteor.call('distToMate', @whoseTurn, @boardModel,
        (err, data) =>
          console.log("white mates in #{(data - 1) // 2}")
        )
    

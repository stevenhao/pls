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
    @computer = 'b'
    
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
    @boardModel.on 'move', @_onMove


  _deselect: (curSquare) =>
    @boardModel.unset('selectedSquare')
    curSquare.set('selected', false)

  _select: (curSquare) =>
    @boardModel.set('selectedSquare', curSquare)
    curSquare.set('selected', true)

  _move: (prvSquare, curSquare) =>
    Meteor.call('validMove', @whoseTurn, @boardModel, prvSquare, curSquare, 
      (err, data) =>
#        console.log('server response: ' + data)
        if !data
          return
        console.log('performing move.')
        prvPiece = prvSquare.get('piece')
        curSquare.set('piece', prvPiece)
        prvSquare.unset('piece')

        @boardModel.trigger('move')
      )

  _onClickSquare: (curSquare) =>
    if @addPiece?
      curSquare.set('piece', @addPiece)
      @addPiece = root.BoardController.next[@addPiece]
    else
      prvSquare = @boardModel.get('selectedSquare')
      if prvSquare?
        @_deselect(prvSquare)
        @_move(prvSquare, curSquare)
      else
        if curSquare.get('piece') and curSquare.get('piece').charAt(0) == @whoseTurn
          @_select(curSquare)

  _onMove: =>
    console.log('piece moved!')
    if @whoseTurn == 'w'
      @whoseTurn = 'b'
    else
      @whoseTurn = 'w'

    if @whoseTurn == @computer
      console.log('making computer move.')
      Meteor.call('bestMove', @whoseTurn, @boardModel, 
        (err, data) =>
          if !data
            return
          console.log('received ' + data)
          frm = @boardModel.getSquareAt(data.frm.row, data.frm.col)
          to = @boardModel.getSquareAt(data.to.row, data.to.col)
          console.log('frm: ' + frm.get('row') + ',' + frm.get('col'))
          console.log('to: ' + to.get('row') + ',' + to.get('col'))
          @_move(frm, to)
        )
      
#  _onRightClickSquare: (curSquare) =>
    

    

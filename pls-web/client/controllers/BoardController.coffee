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


  _deselect: (curSquare) =>
      @boardModel.unset('selectedSquare')
      curSquare.set('selected', false)

  _select: (curSquare) =>
      @boardModel.set('selectedSquare', curSquare)
      curSquare.set('selected', true)

  _validMove: (prvSquare, curSquare) =>
    prvPiece = prvSquare.get('piece')
    curPiece = curSquare.get('piece')
    if prvSquare == curSquare
      return false
    if !prvPiece
      return false
    if prvPiece.charAt(0) != @whoseTurn
      return false
    if curPiece and curPiece.charAt(0) == @whoseTurn
      return false

    prvX = prvSquare.get('row')
    prvY = prvSquare.get('col')
    curX = curSquare.get('row')
    curY = curSquare.get('col')

    console.log('trying to move from ' + prvX + ',' + prvY + ' to ' + curX + ',' + curY)
    if prvPiece.charAt(1) == 'K'
      for dx in _.range(-1, 2)
        for dy in _.range(-1, 2)
          nx = prvX + dx
          ny = prvY + dy
          if nx == curX and ny == curY
            return true
    else if prvPiece.charAt(1) == 'Q'
      for dx in _.range(-1, 2)
        for dy in _.range(-1, 2)
          for len in _.range(1, 8)
            nx = prvX + dx * len
            ny = prvY + dy * len
            if nx < 0 or ny < 0 or nx >= 8 or ny >= 8
              break
            if nx == curX and ny == curY
              return true
            sq = @boardModel.getSquareAt(nx, ny)
            if sq.get('piece')
              break
    else if prvPiece.charAt(1) == 'R'
      for dx in _.range(-1, 2)
        for dy in _.range(-1, 2)
          if dx == 0 or dy == 0
            for len in _.range(1, 8)
             nx = prvX + dx * len
             ny = prvY + dy * len
             if nx < 0 or ny < 0 or nx >= 8 or ny >= 8
               break
             if nx == curX and ny == curY
               return true
             sq = @boardModel.getSquareAt(nx, ny)
             if sq.get('piece')
               break
    return false


  _move: (prvSquare, curSquare) =>
    if @_validMove(prvSquare, curSquare)
      prvPiece = prvSquare.get('piece')
      curSquare.set('piece', prvPiece)
      prvSquare.unset('piece')
      if @whoseTurn == 'w'
        @whoseTurn = 'b'
      else
        @whoseTurn = 'w'

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
      
#  _onRightClickSquare: (curSquare) =>
    

    

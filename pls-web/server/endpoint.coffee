root = exports ? this


if (Meteor.isServer)
  Meteor.methods(
    validMove: (whoseTurn, _board, prvSquare, curSquare) =>
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _validMove(whoseTurn, board, prvSquare, curSquare)

    bestMove: (whoseTurn, _board) =>
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _getBestMove(whoseTurn, board)

    isInCheck: (whoseTurn, _board) =>
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _isInCheck(whoseTurn, board)
  )




_getMovesFrom = (square, board) =>
  piece = square.piece
  if !piece
    return []
  pieceColor = piece.charAt(0)
  pieceType = piece.charAt(1)
  x = square.row
  y = square.col
  ret = []
  for dx in _.range(-1, 2)
    for dy in _.range(-1, 2)
      if dx == 0 and dy == 0
        continue
      for len in _.range(1, 8)
        nx = x + len * dx
        ny = y + len * dy 

        if nx < 0 or ny < 0 or nx >= 8 or ny >= 8
          break
        sq = board.getSquareAt(nx, ny).toJSON()
        sqpiece = sq.piece
        if sqpiece?.charAt(0) == pieceColor
          break

        if pieceType == 'K' and len == 1 or
           pieceType == 'Q' or
           pieceType == 'R' and dx * dy == 0
          ret.push({row: nx, col: ny})

        if sqpiece
          break
  return ret

_getAllMoves = (whoseTurn, board) =>
  ret = []
  for sq in board.get('squares').toJSON()
    if sq.piece?.charAt(0) == whoseTurn
      for dest in _getMovesFrom(sq, board)
        ret.push({frm: sq, to: dest})

  return ret

_isInCheck = (whoseTurn, board) =>
  kpiece = whoseTurn + 'K'
  king = board.getSquareOf(kpiece)
  king = king.toJSON()

  otherTurn = if whoseTurn == 'w' then 'b' else 'w'
  validMoves = _getAllMoves(otherTurn, board)
  for move in validMoves
    if move.to.row == king.row and move.to.col == king.col
      return true
  return false

_isLegalMove = (whoseTurn, move, _board) =>
  board = _board
  #fromsq = board.getSquareAt(move.frm.row, move.frm.col)
  frmsq = board.getSquareAt(move.frm.row, move.frm.col)
  tosq = board.getSquareAt(move.to.row, move.to.col)

  frmpc = frmsq.get('piece')
  topc = tosq.get('piece')
  tosq.set('piece', frmpc)
  frmsq.unset('piece')
  ret = !_isInCheck(whoseTurn, board)
  frmsq.set('piece', frmpc)
  tosq.set('piece', topc)
  return ret

_validMove = (whoseTurn, board, prvSquare, curSquare) =>
  prvPiece = prvSquare.piece
  curPiece = curSquare.piece
  if prvSquare == curSquare
    return false
  if !prvPiece
    return false
  if prvPiece.charAt(0) != whoseTurn
    return false
  if curPiece and curPiece.charAt(0) == whoseTurn
    return false

  if !_isLegalMove(whoseTurn, {frm : prvSquare, to : curSquare}, board)
    return false
  validMoves = _getMovesFrom(prvSquare, board)
  targetRow = curSquare.row
  targetCol = curSquare.col
  for move in validMoves
    if curSquare.row == move.row and curSquare.col == move.col
      return true
  return false

_getLegalMoves = (whoseTurn, board) =>
  movelist = []
  for move in _getAllMoves(whoseTurn, board)
    if _isLegalMove(whoseTurn, move, board)
      movelist.push(move)
  return movelist

_getBestMove = (whoseTurn, board) =>
  allMoves = _getLegalMoves(whoseTurn, board)
  ret = allMoves[~~(Math.random() * allMoves.length)]
  return ret


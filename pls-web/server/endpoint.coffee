root = exports ? this


if (Meteor.isServer)
  console.log('loaded')
  Meteor.methods(
    validMove: (whoseTurn, _board, prvSquare, curSquare) =>
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _validMove(whoseTurn, board, prvSquare, curSquare)
    bestMove: (whoseTurn, _board) =>
      console.log('computing best move.')
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _getBestMove(whoseTurn, board)
  )

_hash = (x, y) =>
  return x * 8 + y

_getBestMove = (whoseTurn, board) =>
  allMoves = _getMoves(whoseTurn, board)
  ret = allMoves[~~(Math.random() * allMoves.length)]
  console.log('picked ' + ret.frm.row + ',' + ret.frm.col + ' to ' + ret.to.row + ',' + ret.to.col)
  return ret

_getMoves = (whoseTurn, board) =>
  console.log('getting moves.')
  ret = []
  for x in _.range(0, 8)
    for y in _.range(0, 8)
      sq = board.getSquareAt(x, y)
      if sq.get('piece')?.charAt(0) == whoseTurn
        for dest in _getMovesFrom(JSON.parse(JSON.stringify(sq)), board)
          ret.push { frm: {row: sq.get('row'), col: sq.get('col')}, to: dest }

  return ret

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
        sq = board.getSquareAt(nx, ny)
        sqpiece = sq.get('piece')
        if sqpiece?.charAt(0) == pieceType
          break

        if pieceType == 'K' and len == 1 or
           pieceType == 'Q' or
           pieceType == 'R' and dx * dy == 0
          ret.push({row: nx, col: ny})

        if sqpiece
          break
  return ret

_validMove = (whoseTurn, board, prvSquare, curSquare) =>
  prvPiece = prvSquare.piece
  curPiece = curSquare.piece
  console.log('testing valid move')
  console.log('prv: ' + prvSquare.row + ', ' + prvSquare.col)
  if prvSquare == curSquare
    return false
  if !prvPiece
    return false
  if prvPiece.charAt(0) != whoseTurn
    return false
  if curPiece and curPiece.charAt(0) == whoseTurn
    return false

  validMoves = _getMovesFrom(prvSquare, board)
  targetRow = curSquare.row
  targetCol = curSquare.col
  for move in validMoves
    if curSquare.row == move.row and curSquare.col == move.col
      return true
  return false

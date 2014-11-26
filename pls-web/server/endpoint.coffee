root = exports ? this




if (Meteor.isServer)
  Meteor.methods(
    validMove: (whoseTurn, _board, prvSquare, curSquare) =>
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _validMove(whoseTurn, board, prvSquare, curSquare)

    getValidMoves: (whoseTurn, _board, prvSquare, curSquare) =>
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _getLegalMoves(whoseTurn, board, prvSquare, curSquare)

    bestMove: (whoseTurn, _board) =>
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _getBestMove(whoseTurn, board)

    isInCheck: (whoseTurn, _board) =>
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _isInCheck(whoseTurn, board)

    isMate: (whoseTurn, _board) =>
      #returns "checkmate", "stalemate", or "not mate"
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      ischeck = _isInCheck(whoseTurn, board)
      legalmoves = _getLegalMoves(whoseTurn, board)
      if legalmoves.length == 0
        if ischeck
          return "checkmate"
        else
          return "stalemate"
      else
        return "not mate"

    distToMate: (whoseTurn, _board) =>
      console.log('computing dist to mate.')
      board = new root.BoardModel(_board)
      board.set('squares', new Backbone.Collection(board.get('squares')))
      return _movesTillMate(whoseTurn, board)

    randomBoard: (mode) =>
      return _randomBoard(mode)
  )

_rand = (lim) =>
  return ~~(Math.random() * lim)


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

  if pieceType == 'N'
    for dx in _.range(-2, 3)
      for dy in _.range(-2, 3)
        if dx * dy == 2 or dx * dy == -2
          nx = x + dx
          ny = y + dy 

          if nx < 0 or ny < 0 or nx >= 8 or ny >= 8
            continue
          sq = board.getSquareAt(nx, ny).toJSON()
          sqpiece = sq.piece
          if sqpiece?.charAt(0) == pieceColor
            continue
          ret.push({row: nx, col: ny})

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

_getRandomMove = (whoseTurn, board) =>
  allMoves = _getLegalMoves(whoseTurn, board)
  ret = allMoves[rand(allMoves.length)]
  return ret

"""
AI PART
 """


_hashSquare = (square) =>
  if square
    return 8 * square.row + square.col
  else
    return 64

_read = (whoseTurn, board) =>
  h = (s) =>
    
    _hashSquare(if s then {row: s.get('row'), col: s.get('col')} else null)

  return {
    turn: if whoseTurn == 'w' then 1 else 0
    K: h(board.getSquareOf('wK'))
    Q: h(board.getSquareOf('wQ'))
    k: h(board.getSquareOf('bK'))
    r: h(board.getSquareOf('bR'))
    n: h(board.getSquareOf('bN'))
  }

ai = {}
_mask = (K, Q, k, r, turn) =>
  return turn + 2 * (r + 65 * (k + 65 * (Q + 65 * K)))

_movesTillMate = (whoseTurn, board) =>
  loc = _read(whoseTurn, board)
  if loc.n == 64
    mode = 'KQkr'
    mask = _mask(loc.K, loc.Q, loc.k, loc.r, loc.turn)
    ans = ai[mode].charCodeAt(mask) - 40
  else if loc.r == 64
    mode = 'KQkn'
    mask = _mask(loc.K, loc.Q, loc.k, loc.n, loc.turn)
    ans = ai[mode].charCodeAt(mask) - 40

  console.log("mode: #{mode}")
  if ans == -1
    ans = 200

  return ans

_getBestMove = (whoseTurn, board) =>
  console.log('finding best move.')
  allMoves = _getLegalMoves(whoseTurn, board)
  otherTurn = if whoseTurn == 'b' then 'w' else 'b'
  goodMoves = []
  bestDist = if whoseTurn == 'b' then 0 else 200
  for move in allMoves
    frmsq = board.getSquareAt(move.frm.row, move.frm.col)
    tosq = board.getSquareAt(move.to.row, move.to.col)
    frmpc = frmsq.get('piece')
    topc = tosq.get('piece')
    tosq.set('piece', frmpc)
    frmsq.unset('piece')
    cur = _movesTillMate(otherTurn, board)

    if (whoseTurn == 'b' and cur > bestDist) or (whoseTurn == 'w' and cur < bestDist)
      bestDist = cur
      goodMoves = []
    if cur == bestDist
      goodMoves.push(move)
    frmsq.set('piece', frmpc)
    tosq.set('piece', topc)
  console.log("found #{goodMoves.length} moves which are dist of #{bestDist}")
  return goodMoves[~~(Math.random() * goodMoves.length)]

_loadAIWeb = () =>
  console.log('loading ai from web.')
  ai['KQkr'] = Meteor.http.get('http://mit.edu/hsteven/Public/KQkr.txt').content
  console.log('KQkr loaded')
  ai['KQkn'] = Meteor.http.get('http://mit.edu/hsteven/Public/KQkn.txt').content
  console.log('KQkn loaded')
  console.log('loaded ai.')

_loadAILocal = () =>
  console.log('loading ai locally.')
  fs.readFile('../../../../../../AI/files/KQkr', (err, data) =>
    console.log('reading KQkr.')
    if err
      console.log('error: ' + err)
      return
    ai['KQkr'] = "" + data
    console.log('done reading KQkr.')
    )  
  fs.readFile('../../../../../../AI/files/KQkn', (err, data) =>
    console.log('reading KQkn.')
    if err
      console.log('error: ' + err)
      return
    ai['KQkn'] = "" + data
    console.log('done reading KQkn.')
    )


fs = Npm.require('fs')
_loadAIWeb()
#_loadAILocal()




# generate random starting position

_valid = (a, b, c, d) =>
  h = (a, b) =>
    return !(a.row == b.row and a.col == b.col)
  return h(a, b) and h(a, c) and h(a, d) and h(b, c) and h(b, d) and h(c, d)

_randomSquare = =>
  return {row: _rand(8), col: _rand(8)}

_randomBoard = (mode) =>
  h = _hashSquare
  if mode == 'KQkr'
    for i in _.range(100)
      K = _randomSquare()
      Q = _randomSquare()
      k = _randomSquare()
      r = _randomSquare()
      if _valid(K, Q, k, r)
        console.log('valid')
        mask = _mask(h(K), h(Q), h(k), h(r), 1)
        console.log("mask = #{mask}")
        ans = ai[mode].charCodeAt(mask) - 40
        console.log("dist is #{ans}")
        if ans >= 40
          return {K: K, Q: Q, k: k, r: r}
      else
        console.log('invalid')
  else if mode == 'KQkn'
    for i in _.range(100)
      K = _randomSquare()
      Q = _randomSquare()
      k = _randomSquare()
      n = _randomSquare()
      if _valid(K, Q, k, n)
        console.log('valid')
        mask = _mask(h(K), h(Q), h(k), h(n), 1)
        console.log("mask = #{mask}")
        ans = ai[mode].charCodeAt(mask) - 40
        console.log("dist is #{ans}")
        if ans >= 30
          return {K: K, Q: Q, k: k, n: n}
      else
        console.log('invalid')



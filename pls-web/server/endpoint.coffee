root = exports ? this

if (Meteor.isServer)
  console.log('loaded')
  Meteor.methods(
    yo: =>
      console.log('hi')



    validMove: (whoseTurn, _board, _prvSquare, _curSquare) =>
      prvSquare = new Backbone.Model(_prvSquare)
      curSquare = new Backbone.Model(_curSquare)
      board = new Backbone.Model(_board)

      console.log('doing server stuff')
      console.log('received ' + whoseTurn + ',' + board)
      console.log('prvPiece = ' + prvSquare.get('piece'))
      prvPiece = prvSquare.get('piece')
      curPiece = curSquare.get('piece')
      if prvSquare == curSquare
        return false
      if !prvPiece
        return false
      if prvPiece.charAt(0) != whoseTurn
        return false
      if curPiece and curPiece.charAt(0) == whoseTurn
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
              sq = board.getSquareAt(nx, ny)
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
               sq = board.getSquareAt(nx, ny)
               if sq.get('piece')
                 break
      return false
  )
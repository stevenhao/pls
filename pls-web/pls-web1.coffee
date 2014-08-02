root = exports ? this
if (Meteor.isClient)
  $(document).ready ->
    console.log 'document is ready'
    board = new root.BoardView
      one: 1
      two: 2

    board.render()
    console.log $('.chess-board-container')
    $('.chess-board-container').html(board.$el)



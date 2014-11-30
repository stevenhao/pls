# exports in a way to make things global
# we are basically saying, if exports doesn't exist yet, root should be
# an object that contains this file
root = exports ? this

# we prepend classes with `root.` so that we are defining them in
# the root object, which is accessible in all other files that
# have the `root = exports ? this` line.
class root.BoardController


  initialize: ->
    @_setUpBoardModel()
    @_setUpBoardViewModel()
    @_createBoardView()
    @_createControlsView()

    @computer = {
      'w': 0
      'b': 1
    }

    $('.color-selector').on('click', @_onColorSelected)
    $('.go-button').on('click', @_compmove)

  _createControlsView: =>
    @_controlsView = new root.ControlsView
      el: $('.left-side-bar')
      model: @_viewModel

    @_controlsView.on 'resetBoard', @_resetBoard
    @_controlsView.on 'callRandomBoard', @_onCallRandomBoard
    @_controlsView.on 'triggerNextMove', @_nextmove

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

  _setUpBoardViewModel: =>
    @_viewModel = new root.BoardViewModel
      'mode': root.BoardViewModel.MODE_ONE

  _onColorSelected: (evt) =>
    checkbox = $(evt.currentTarget)
    if checkbox.attr('checked')
      checkbox.removeAttr('checked')
    else
      checkbox.attr('checked', 'checked')
    @computer[checkbox.attr('name')] = checkbox.attr('checked')

  _deselect: =>
    curSelected = @_viewModel.get('curSelected')
    curSelected.set('selected', false)
    @_viewModel.unset('curSelected')
    @boardModel.get('squares').each (sq) =>
      sq.set('validMove', false)

  _eqSq: (a, b) =>
        return a.get('row') == b.row and a.get('col') == b.col

  _select: (curSquare) =>
    curSquare.set('selected', true)
    @_viewModel.set('curSelected', curSquare)
    _.each @_viewModel.get('validMoves'), (mv) =>
      r = mv.to.row
      c = mv.to.col
      if @_eqSq(curSquare, mv.frm)
        @boardModel.getSquareAt(r, c).set('validMove', true)

  _validMove: (prvSquare, curSquare) =>
    ret = false
    _.each @_viewModel.get('validMoves'), (mv) =>
      if @_eqSq(prvSquare, mv.frm) and @_eqSq(curSquare, mv.to)
        ret = true
    return ret

  _move: (prvSquare, curSquare) =>
    if @_validMove(prvSquare, curSquare)
      prvPiece = prvSquare.get('piece')
      curSquare.set('piece', prvPiece)
      prvSquare.unset('piece')
      @boardModel.trigger('move')
    else

  _onClickSquare: (curSquare) =>
    if @_viewModel.get('addPiece')?
      curSquare.set('piece', @_viewModel.get('addPiece'))
      mode = @_viewModel.get('mode')
      @_viewModel.setNextAddPiece()
    else
      prvSquare = @_viewModel.get('curSelected')
      if prvSquare
        @_deselect()
        if prvSquare != curSquare
          @_move(prvSquare, curSquare)
      else
        if curSquare.get('piece') and
          curSquare.get('piece').charAt(0) == @_viewModel.get('whoseTurn')
            @_select(curSquare)


  _onMove: =>
    @_viewModel.toggleWhoseTurn()
    @_makeServerCall 'isMate', (err, data) =>
      if data == 'checkmate'
        alert('Checkmate!')
      else if data == 'stalemate'
        alert('Stalemate!')
      else
        @_nextmove()

  _compmove: =>
    @_makeServerCall 'bestMove', (err, data) =>
      if !data
        return
      frm = @boardModel.getSquareAt(data.frm.row, data.frm.col)
      to = @boardModel.getSquareAt(data.to.row, data.to.col)
      @_move(frm, to)

  _onCallRandomBoard: =>
    put = (square, piece) =>
      if square?
        @boardModel.getSquareAt(square.row, square.col).set('piece', piece)

    Meteor.call 'randomBoard', @_viewModel.get('mode'), (err, data) =>
      if data
        put(data.K, 'wK')
        put(data.Q, 'wQ')
        put(data.k, 'bK')
        put(data.r, 'bR')
        put(data.n, 'bN')
        @_viewModel.set('addPiece', null)

  _resetBoard: =>
    @boardModel.get('squares').each (p) =>
      p.unset('piece')
      p.set('validMove', false)
      p.set('selected', false)

  _nextmove: =>
    console.log 'next move!'
    @_makeServerCall 'getValidMoves', (err, data) =>
        @_viewModel.set('validMoves', data)

    if @computer[@_viewModel.get('whoseTurn')]
      @_compmove()
    else
      @_makeServerCall 'isInCheck', (err, data) =>
        if data
          console.log 'check'

    @_makeServerCall 'distToMate', (err, data) =>
      console.log 'dist to mate', data//2

  _makeServerCall: (method, callback) ->
    Meteor.call method, @_viewModel.get('whoseTurn'), @boardModel, callback



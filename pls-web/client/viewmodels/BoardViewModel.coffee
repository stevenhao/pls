root = exports ? this

class root.BoardViewModel extends Backbone.Model
  @MODE_ONE: 'KQkr'
  @MODE_TWO: 'KQkn'

  @NEXT:
    'KQkr':
      'wK': 'wQ'
      'wQ': 'bK'
      'bK': 'bR'
      'bR': null
    'KQkn':
      'wK': 'wQ'
      'wQ': 'bK'
      'bK': 'bN'
      'bN': null

  defaults:
    whoseTurn: 'w'
    curSelected: null
    mode: 'KQkr'
    validMoves: []
    addPiece: 'wK'

  toggleWhoseTurn: ->
    whoseTurn = if @get('whoseTurn') is 'w' then 'b' else 'w'
    @set('whoseTurn', whoseTurn)

  reset: ->
    @clear().set(@defaults)

  setNextAddPiece: ->
    newAddPiece = root.BoardViewModel.NEXT[@get('mode')][@get('addPiece')]
    @set('addPiece', newAddPiece)

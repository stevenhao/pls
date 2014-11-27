root = exports ? this

class root.BoardViewModel extends Backbone.Model
  defaults:
    whoseTurn: 'w'
    curSelected: null
    # vaildMoves: []

  toggleWhoseTurn: ->
    whoseTurn = if @get('whoseTurn') is 'w' then 'b' else 'w'
    @set('whoseTurn', whoseTurn)

  reset: ->
    @clear().set(@defaults)
root = exports ? this

class root.ControlsView extends Backbone.View
  events:
    'click .reset-button': '_onReset'
    'click .mode-selector': '_onModeClick'

  initialize: ->
    @model.on 'change:addPiece', @_checkState
    @_renderMode()

  _onReset: =>
    if @model.get('addPiece') is 'wK'
      @trigger 'callRandomBoard'
    else
      @model.reset()
      @model.set('addPiece', 'wK')
      @trigger 'resetBoard'

  _checkState: =>
    if @model.get('addPiece') == 'wK'
      $('.reset-button').attr('value', 'Random!')
    else
      $('.reset-button').attr('value', 'Clear!')

    if not @model.get('addPiece')?
      @trigger 'triggerNextMove'

  _onModeClick: =>
    @model.toggleMode()
    @_renderMode()

  _renderMode: =>
    @$('.mode-selector').attr('value', "Playing #{@model.get('mode')}")
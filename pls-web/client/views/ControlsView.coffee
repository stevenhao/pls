root = exports ? this

class root.ControlsView extends Backbone.View
  events:
    'click .reset-button': '_onReset'
    'click .dropdown-menu-item': '_onModeItemClick'

  initialize: ->
    @model.on 'change:addPiece', @_checkState
    @model.on 'change:mode', @_renderMode
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

  _onModeItemClick: (evt) =>
    mode = $(evt.target).data('mode')
    @model.set('mode', mode)

  _createDropdownModeSelector: (mode) ->
    return $("<li role='presentation'>
          <a class='dropdown-menu-item' role='menuitem' tabindex='-1' data-mode='#{mode}'>Play #{mode}</a>
        </li>")

  _renderMode: =>
    @$('.dropdown-menu').html('')
    @$('.dropdown-menu').append(@_createDropdownModeSelector(root.BoardViewModel.MODE_ONE))
    @$('.dropdown-menu').append(@_createDropdownModeSelector(root.BoardViewModel.MODE_TWO))

    @$('.dropdown button').html("Playing #{@model.get('mode')} <span class='caret'></span>")

root = exports ? this

class root.ControlsView extends Backbone.View
  events:
    'click .random-button': '_onRandom'
    'click .clear-button': '_onClear'
    'click .dropdown-menu-item': '_onModeItemClick'

  initialize: ->
    @model.on 'change:addPiece', @_checkButtonState
    @model.on 'change:mode', @_renderMode
    @_renderMode()
    @_checkButtonState()

  _onRandom: ->
    @trigger 'callRandomBoard'

  _onClear: ->
    @model.reset()
    @trigger 'resetBoard'

  _checkButtonState: =>
    if @model.get('addPiece') == 'wK'
      @$('.clear-button').attr('disabled', true)
      @$('.random-button').removeAttr('disabled')
    else
      @$('.clear-button').removeAttr('disabled', true)
      @$('.random-button').attr('disabled', true)

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

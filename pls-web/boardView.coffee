root = exports ? this

class root.Board extends Backbone.View
  initialize: (options) ->
    console.log options

  render: ->
    console.log 'render'
    @$el.append("yo")

    for row in _.range(8)
      rowEl = $ '<div/>',
        class: 'row'
        id: "row#{row}"
      for col in _.range(8)
        square = $ '<div/>',
          class: 'square'
          id: "square#{row},#{col}"
        rowEl.append(square)
      @$el.append(rowEl)
      # console.log Template.square
      # view = Template.square()
      # console.log 'view'




  boo: ->
    console.log 'boo'

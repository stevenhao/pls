## Packages used

 - [Backbone](http://backbonejs.org/)
 - [Underscore](http://underscorejs.org/)
 - [less](http://lesscss.org/)
 - [jQuery](https://jquery.com/)

## Model-View-Controller
I think it's more correct to have an MV setup, but I don't really understand it, so I like to add in controllers :)


Check out [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)

### Main points:
#### Set up
 - the view does not have any state, the model contains all the state.
 - the view doesn't really do much logic, the controller does the logic
 - Each view usually has one main model that stores all state for that view. (e.g. one SquareModel for one SquareView)
 - views can be destroyed frequently, but it is usual for models to be created once and kept for the whole duration

#### Rendering the view
 - the view is only in charge of rendering itself and its child views
 - the view, or parts of the view, can be continuously re-rendered, according to what the model says.
 - the view should listen to events from the model, to know when it should re-render

#### Manipulating the view
 - the view listens to DOM events, such as clicks
 - the view can change its own model attributes using the [`set`](http://backbonejs.org/#Model-set) method
 - the view can also trigger events on the model using the [`trigger`](http://backbonejs.org/#Events-trigger) method

#### Logic
 - when things happen, the controller should orchestrate what follows
 - the controller can listen to events on the model using the [`on`](http://backbonejs.org/#Events-on) method
 - it is common to have one main controller for each separate component of the application

#### Events
 - you can listen to events using the [`on`](http://backbonejs.org/#Events-on) method
 - it is common to name callbacks from events of the form `_on event name` e.g. `_onClick` or `onChangePiece`.
 - you can trigger an event on Backbone View or Backbone Model. Anyone listening for that specific event will be notified

#### Notes
 - you access attributes on a Backbone.Model via the [`get`](http://backbonejs.org/#Model-get) method.
 - **This is important!** don't try to do `model.color` when it should be `model.get('color')`
 - the view should not know about the existence of its parent views or the controller
 - all outgoing communication from the view is through its model or a parent model
 - the view shouldn't really do any logic at all
 - the model shouldn't do much logic, but it is acceptable to have helper methods on the model when necessary

### Backbone is awesome
 - we like to use [Backbone.Models](http://backbonejs.org/#Model) over object hashes because it does a lot of logic for you, and is easier to use
 - we prefer [Backbone.Collections](http://backbonejs.org/#Collection) of Backbone.Models over arrays because they do more logic for you (such as keeping unique models)
 - [Backbone.Views](http://backbonejs.org/#View) are simple javascript classes that have the `el` and `$el` attributes.
 - `el` is a simple DOM element, and is accessed as `@el`. You rarely use this.
 - `$el` is a [jQuery wrapper](https://api.jquery.com/jquery/) around the DOM element, and is accessed as `@$el`. You use this most of the time.
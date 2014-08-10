root = exports ? this
if (Meteor.isClient)
  $(document).ready ->
    controller = new root.BoardController()
    controller.initialize()

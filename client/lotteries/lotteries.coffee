Template.lotteries.helpers
  lotteries: ->
    # sort lotteries by creation date (newest first)
    Lotteries.find {}, sort:
      createdAt: -1

Template.lotteries.events
 'submit .new-lottery': (evt) ->
    evt.preventDefault()
    name = evt.target.name.value
    # add new lottery to DB
    Meteor.call 'addLottery', name
    # Clear form
    evt.target.name.value = ""

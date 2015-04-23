Template.body.helpers
  showLotteries: ->
    # only show lottery page when user is logged in
    Meteor.user()?

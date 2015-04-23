Template.participant.helpers
  isMe: ->
    # the participant is the current logged in user
    Meteor.user().username == @username

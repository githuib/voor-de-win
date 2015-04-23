Template.lottery.created = ->
  this.countdown = new (ReactiveVar)('')

Template.lottery.helpers
  showJoin: ->
    # only show "Join" button when user is not already participating in the lottery and the lottery is not started yet
    lottery = Lotteries.findOne {_id: @_id}
    participantIds = (p._id for p in lottery.participants)
    Meteor.userId() not in participantIds && not lottery.winner? && Template.instance().countdown.get() == ''

  showPlay: ->
    # show "Play" button when there is at least one other player and the lottery is not started yet
    lottery = Lotteries.findOne {_id: @_id}
    lottery.participants.length > 1 && not lottery.winner? && Template.instance().countdown.get() == ''

  showWinner: ->
    # show the winner when the lottery is finished
    lottery = Lotteries.findOne {_id: @_id}
    lottery.winner? || Template.instance().countdown.get() != ''

  countdown: ->
    # bind value of "countdown" element to reactive variable
    Template.instance().countdown.get()

  isMe: ->
    # logged in user has won
    lottery = Lotteries.findOne {_id: @_id}
    lottery.winner._id == Meteor.userId()

  isOther: ->
    # Someone else has won
    lottery = Lotteries.findOne {_id: @_id}
    lottery.winner? && lottery.winner._id != Meteor.userId()

Template.lottery.events
  'click .join': (evt) ->
    # let current user join a lottery
    Meteor.call 'joinLottery', @_id, Meteor.user()

  'click .start': (evt, template) ->
    lotteryId = @_id
    # let current user join a lottery
    lottery = Lotteries.findOne {_id: lotteryId}
    winner = lottery.participants[Math.floor(Math.random() * lottery.participants.length)]

    # start countdown
    count = 30
    template.countdown.set count
    interval = setInterval((->
      count = count - 1
      if count == 0
        clearInterval interval
        # update winner in DB
        Meteor.call 'winLottery', lotteryId, winner
        # clear countdown element
        template.countdown.set ''
      else
        # rotate to participant names in countdown element
        template.countdown.set lottery.participants[count % lottery.participants.length].username
    ), 100)

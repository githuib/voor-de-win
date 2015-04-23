# COLLECTIONS

Lotteries = new (Mongo.Collection)('lotteries')


# CLIENT

if Meteor.isClient

  Meteor.subscribe 'lotteries'

  accountsUIBootstrap3.setLanguage 'nl'

  # body

  Template.body.helpers
    showLotteries: ->
      Meteor.user()?

  # lotteries

  Template.lotteries.helpers
    lotteries: ->
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

  # lottery

  Template.lottery.created = ->
    this.countdown = new (ReactiveVar)('')

  Template.lottery.helpers
    showJoin: ->
      lottery = Lotteries.findOne {_id: @_id}
      participantIds = (p._id for p in lottery.participants)
      Meteor.userId() not in participantIds
    showPlay: ->
      lottery = Lotteries.findOne {_id: @_id}
      lottery.participants.length > 1 && not lottery.winner? && Template.instance().countdown.get() == ''
    showWinner: ->
      lottery = Lotteries.findOne {_id: @_id}
      lottery.winner? || Template.instance().countdown.get() != ''
    countdown: ->
      Template.instance().countdown.get()

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
          template.countdown.set ''
        else
          template.countdown.set lottery.participants[count % lottery.participants.length].username
      ), 100)

  # accounts

  Accounts.ui.config
    passwordSignupFields: 'USERNAME_ONLY'


# SERVER

if Meteor.isServer

#  Meteor.startup ->
#    # code to run on server at startup

  Meteor.publish 'lotteries', ->
    Lotteries.find()


# METHODS

Meteor.methods
  addLottery: (lotteryName) ->
    if not Meteor.userId()?
      throw new Meteor.Error 'not-authorized'

    Lotteries.insert
      name: lotteryName
      createdAt: new (Date)()
      participants: [Meteor.user()]

  joinLottery: (lotteryId, participant) ->
    if not Meteor.userId()?
      throw new Meteor.Error 'not-authorized'

    Lotteries.update
      _id: lotteryId
    , $addToSet:
        participants: participant

  winLottery: (lotteryId, winner) ->
    if not Meteor.userId()?
      throw new Meteor.Error 'not-authorized'

    Lotteries.update
      _id: lotteryId
    , $set:
        winner: winner

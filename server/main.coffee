Meteor.publish 'lotteries', ->
  Lotteries.find()


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

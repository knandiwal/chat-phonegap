chatModule = angular.module "chat", []

chatModule.config ($routeProvider)->
  $routeProvider.when('/chatWith/:name',
    templateUrl: 'chat_with.html'
    controller: 'ChatCtrl').
    when('/',
      templateUrl: 'chat_hall.html'
      controller: 'ChatHallCtrl'
    )

chatModule.service 'chatData', ->
  currentUser: null
  totalMsgs: []
  setCurrentUser: (user) ->
    this.currentUser = user
  sendMsg: (msg) ->
    pair =  _.find this.totalMsgs, (pair)-> pair.partner == msg.receiver
    if pair
      pair.groupMsgs.push(msg)
    else
      pair = { partner: msg.receiver, groupMsgs: []}
      pair.groupMsgs.push(msg)
      this.totalMsgs.push(pair)
  receiveMsg: (msg) ->
      # Not implemented

chatModule.controller 'ChatHallCtrl', ($scope, chatData)->
  $scope.connectedChatters = []
  $scope.joined = false

  # for local test
  $scope.connectedChatters.push('Tester')
  $scope.connectedChatters.push('Anny')
  # END

  $scope.join = ->
    # $scope.connectedChatters.
    # define socket here
    $scope.joined = true
    chatData.setCurrentUser({name: $scope.username})
    # $scope.currentUser = {username: $scope.username}
    # $window.currentUser = $scope.currentUser

chatModule.controller 'ChatCtrl', ($scope, $routeParams, chatData)->
  $scope.partner = {name: $routeParams.name || 'None'}
  $scope.currentUser = chatData.currentUser

  $scope.getMsgs = ->
    $scope.msgs = _.find chatData.totalMsgs, (msg)->
      msg.partner == $scope.partner

  $scope.send = ->
    msg = { sender: $scope.currentUser, receiver: $scope.partner, content: $scope.msgContent }
    chatData.sendMsg(msg)
    $scope.getMsgs()

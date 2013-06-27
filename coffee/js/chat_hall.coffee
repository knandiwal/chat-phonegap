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
  currentSocket: null
  totalMsgs: []
  setCurrentUser: (user) ->
    this.currentUser = user
  sendMsg: (msg) ->
    pair =  _.find this.totalMsgs, (group)-> _.isEqual(group.partner, msg.receiver)
    if pair
      pair.groupMsgs.push(msg)
    else
      pair = { partner: msg.receiver, groupMsgs: [] }
      pair.groupMsgs.push(msg)
      this.totalMsgs.push(pair)
  receiveMsg: (msg) ->
    pair = _.find this.totalMsgs, (group)-> _.isEqual(group.partner, msg.sender)
    if pair
      pair.groupMsgs.push(msg)
    else
      pair = { partner: msg.sender, groupMsgs: [] }
      pair.groupMsgs.push(msg)
      this.totalMsgs.push(pair)

chatModule.controller 'ChatHallCtrl', ($scope, chatData)->
  $scope.connectedChatters = []
  $scope.joined = false

  # for local test
  $scope.connectedChatters.push('Tester')
  $scope.connectedChatters.push('Anny')
  # END

  $scope.join = ->
    socket = io.connect("http://localhost:3333")
    socket.on 'init_chatters', (chatters)->
      $scope.connectedChatters = _.reject chatters, (cr)-> cr == $scope.username
      $scope.joined = true
      $scope.$apply()

    socket.on 'chatters', (chatters)->
      $scope.connectedChatters = _.reject chatters, (cr)-> cr == $scope.username
      $scope.$apply()

    socket.on 'receive p2p msg', (msg)->
      chatData.receiveMsg(msg)
      e = angular.element(document.querySelector("##{msg.receiver.name}-to-#{msg.sender.name}"))
      if e
        e.scope().getMsgs()
        e.scope().$apply()
      # else should update the msg count on hall page

    socket.emit 'join', $scope.username
    chatData.currentSocket = socket
    chatData.setCurrentUser({name: $scope.username})

chatModule.controller 'ChatCtrl', ($scope, $routeParams, chatData)->
  $scope.partner = {name: $routeParams.name || 'None'}
  $scope.currentUser = chatData.currentUser

  $scope.getMsgs = ->
    $scope.msgs = _.find chatData.totalMsgs, (msg)->
      _.isEqual(msg.partner, $scope.partner)

  $scope.getMsgs() # init msgs when controller first init

  $scope.send = ->
    msg = { sender: $scope.currentUser, receiver: $scope.partner, content: $scope.msgContent }
    chatData.sendMsg(msg)
    $scope.getMsgs()
    chatData.currentSocket.emit 'p2p msg', msg
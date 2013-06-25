chatModule = angular.module("chat", []);

chatModule.controller 'ChatHallCtrl', ($scope)->
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

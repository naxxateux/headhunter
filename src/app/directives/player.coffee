app.directive 'player', ($document) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/player.html'
  scope:
    dates: '='
    currentDate: '='
  link: ($scope, $element, $attrs) ->
    $scope.isPlaying = false

    $scope.playButtonClick = ->
      $scope.isPlaying = true
      return

    $scope.stopButtonClick = ->
      $scope.isPlaying = false
      return
    return

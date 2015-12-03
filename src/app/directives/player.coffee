app.directive 'player', ($document) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/player.html'
  scope:
    dates: '='
    currentDate: '='
  link: ($scope, $element, $attrs) ->
    $scope.isPlaying = false
    $scope.isPlayButtonDisabled = false
    intervalId = undefined

    $scope.playButtonClick = ->
      $scope.isPlaying = true
      dateIndex = _.findIndex $scope.dates, $scope.currentDate
      dateIndex++

      if dateIndex is $scope.dates.length
        $scope.isPlaying = false
        clearInterval intervalId

      intervalId = setInterval ->
        if dateIndex is $scope.dates.length
          $scope.isPlaying = false
          clearInterval intervalId
        else
          $scope.currentDate = $scope.dates[dateIndex]
          dateIndex++
        $scope.$apply()
        return
      , 500
      return

    $scope.stopButtonClick = ->
      $scope.isPlaying = false
      clearInterval intervalId
      return

    $scope.$watch 'currentDate', ->
      dateIndex = _.findIndex $scope.dates, $scope.currentDate
      $scope.isPlayButtonDisabled = dateIndex is $scope.dates.length - 1
      return
    return

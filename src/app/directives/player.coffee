app.directive 'player', ($document) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/player.html'
  scope:
    dates: '='
    currentDate: '='
  link: ($scope, $element, $attrs) ->
    $scope.isPlaying = false
    intervalId = undefined

    $scope.playButtonClick = ->
      $scope.isPlaying = true
      dateIndex = _.findIndex $scope.dates, $scope.currentDate
      dateIndex++

      if dateIndex is $scope.dates.length
        dateIndex = 0
        $scope.currentDate = $scope.dates[dateIndex]

      intervalId = setInterval ->
        if dateIndex is $scope.dates.length
          $scope.isPlaying = false
          clearInterval intervalId
        else
          $scope.currentDate = $scope.dates[dateIndex]
          dateIndex++
        $scope.$apply()
        return
      , 180
      return

    $scope.stopButtonClick = ->
      $scope.isPlaying = false
      clearInterval intervalId
      return

    $scope.$watch 'currentDate', -> dateIndex = _.findIndex $scope.dates, $scope.currentDate

    return

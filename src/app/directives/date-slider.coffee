app.directive 'dateSlider', ($document) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/date-slider.html'
  scope:
    dates: '='
    currentDate: '='
    monthNames: '='
  link: ($scope, $element, $attrs) ->
    sliderWidth = $element[0].getBoundingClientRect().width
    sliderLeftOffset = $element.offset().left
    $handle = $element.find '.date-slider__handle'
    nOfMonths = $scope.dates.length
    step = sliderWidth / nOfMonths

    $scope.handleShift = ($handle.width() - 1) / 2
    $scope.currentX = $scope.currentDate.moment.diff($scope.dates[0].moment, 'months') * step

    $scope.getDateX = (date) ->
      date.moment.diff($scope.dates[0].moment, 'months') * step

    $scope.getCaptionText = (date, isStart) ->
      month = date.moment.month()
      year = date.moment.year()

      if isStart or !month
        $scope.monthNames[month].short + '<br>' + year
      else
        $scope.monthNames[month].short

    $handle.on 'mousedown', (event) ->
      $('body').css cursor: 'pointer'

      mousemove = (event) ->
        monthsFromStart = Math.floor (event.clientX - sliderLeftOffset) / step
        monthsFromStart = 0 if monthsFromStart < 0
        monthsFromStart = nOfMonths - 1 if monthsFromStart > nOfMonths - 1

        $scope.currentX = monthsFromStart * step
        $scope.currentDate = $scope.dates[monthsFromStart]

        $scope.$apply()
        return

      mouseup = ->
        $('body').css cursor: 'auto'
        $document.unbind 'mousemove', mousemove
        $document.unbind 'mouseup', mouseup
        return

      event.preventDefault()
      $document.on 'mousemove', mousemove
      $document.on 'mouseup', mouseup
      return

    return

app.directive 'legend', ($document) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/legend.html'
  scope:
    data: '='
    lastDate: '='
    currentDate: '='
    colorScale: '='
    activeIndustries: '='
  link: ($scope, $element, $attrs) ->
    $scope.getLastDateAvgSalary = (data) -> _.find(data, {'date': $scope.lastDate}).avgSalary

    $scope.getLastDateNOfJobs = (data) -> _.find(data, {'date': $scope.lastDate}).nOfJobs

    $scope.getCurrentDateAvgSalary = (data) ->
      avgSalary = _.find(data, {'date': $scope.currentDate}).avgSalary

      if avgSalary isnt 1000
        (avgSalary * 0.001).toFixed()
      else
        ''

    $scope.isIndustryActive = (industry) ->
      unless $scope.activeIndustries.length
        true
      else
        $scope.activeIndustries.indexOf(industry) isnt -1

    $scope.industryClick = (industry) ->
      industryIndex = $scope.activeIndustries.indexOf industry

      if industryIndex is -1
        $scope.activeIndustries.push industry
      else
        $scope.activeIndustries.splice industryIndex, 1

    return

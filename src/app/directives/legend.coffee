app.directive 'legend', ($document) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/legend.html'
  scope:
    data: '='
    lastDate: '='
    model: '='
    colorScale: '='
  link: ($scope, $element, $attrs) ->
    $scope.getLastDateAvgSalary = (data) -> _.find(data, {'date': $scope.lastDate}).avgSalary

    $scope.getLastDateNOfJobs = (data) -> _.find(data, {'date': $scope.lastDate}).nOfJobs

    $scope.getCurrentDateAvgSalary = (data) ->
      avgSalary = _.find(data, {'date': $scope.model.currentDate}).avgSalary

      if avgSalary isnt 1000
        (avgSalary * 0.001).toFixed()
      else
        ''

    $scope.isIndustryActive = (industry) ->
      unless $scope.model.activeIndustries.length
        true
      else
        $scope.model.activeIndustries.indexOf(industry) isnt -1

    $scope.industryClick = (industry) ->
      industryIndex = $scope.model.activeIndustries.indexOf industry

      if industryIndex is -1
        $scope.model.activeIndustries.push industry
      else
        $scope.model.activeIndustries.splice industryIndex, 1

    return

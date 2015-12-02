app.directive 'chart', ($timeout) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/chart.html'
  scope:
    data: '='
    dates: '='
    currentDate: '='
  link: ($scope, $element, $attrs) ->
    element = $element[0]
    d3element = d3.select element

    outerWidth = $element.parent().width()
    outerHeight = $element.parent().height()

    padding =
      top: 20
      right: 40
      bottom: 20
      left: 40

    width = outerWidth - padding.left - padding.right
    height = outerHeight - padding.top - padding.bottom

    svg = d3element.append 'svg'
    .classed 'chart__svg', true
    .attr 'width', outerWidth
    .attr 'height', outerHeight

    g = svg.append 'g'
    .classed 'main', true
    .attr 'transform', 'translate(' + padding.left + ', ' + padding.top + ')'

    xExtent = [0, -Infinity]
    yExtent = [0, -Infinity]

    $scope.dates.forEach (date) ->
      _.keys($scope.data).forEach (key) ->
        dataPiece = _.find $scope.data[key], {'date': date}

        xExtent[1] = Math.max xExtent[1], dataPiece.nOfJobs
        yExtent[1] = Math.max yExtent[1], dataPiece.nOfCVs
        return
      return

    xExtent[1] = xExtent[1] * 1.1
    yExtent[1] = yExtent[1] * 1.1

    x = d3.scale.linear()
    .domain xExtent
    .range [0, width]

    y = d3.scale.linear()
    .domain yExtent
    .range [height, 0]

    tickFormat = (d) ->
      d * 0.001

    xAxis = d3.svg.axis()
    .scale x
    .orient 'bottom'
    .tickSize 3
    .tickFormat tickFormat

    yAxis = d3.svg.axis()
    .scale y
    .orient 'left'
    .tickSize 3
    .tickFormat tickFormat

    g.append 'g'
    .attr 'class', 'axis x-axis'
    .attr 'transform', 'translate(0, ' + height + ')'
    .call xAxis
    .append 'text'
    .attr 'class', 'axis-title'
    .attr 'x', width
    .attr 'y', 0
    .attr 'dy', '-.71em'
    .style 'text-anchor', 'end'
    .text 'Ср. кол-во вакансий, тыс. шт.'


    g.append 'g'
    .attr 'class', 'axis y-axis'
    .call yAxis
    .append 'text'
    .attr 'class', 'axis-title'
    .attr 'x', 6
    .attr 'y', 0
    .attr 'dy', '.32em'
    .style 'text-anchor', 'start'
    .text 'Ср. кол-во резюме, тыс. шт.'

    industryCirclesGroup = g.append 'g'
    .attr 'class', 'industry-circles'

    _.keys($scope.data).forEach (key) ->
      industryCircleGroup = industryCirclesGroup.append 'g'
      .attr 'class', 'industry-circle'
      .datum $scope.data[key]

      industryCircleGroup.append 'circle'
      .attr 'cx', 0
      .attr 'cy', 0
      .attr 'r', 0
      .style 'fill', '#549fab'
      .style 'stroke', 'none'
      .style 'stroke-width', 0
      .style 'opacity', .7
      return

    updateGraph = ->
      console.log 'Graph updated → ' + $scope.currentDate.moment.format('MMMM YYYY')

      industryCirclesGroup.selectAll '.industry-circle'
      .transition()
      .duration 500
      .attr 'transform', (d) ->
        dataPiece = _.find d, {'date': $scope.currentDate}
        'translate(' + x(dataPiece.nOfJobs) + ', ' + y(dataPiece.nOfCVs) + ')'
      .select 'circle'
      .transition()
      .duration 500
      .attr 'r', (d) ->
        dataPiece = _.find d, {'date': $scope.currentDate}
        Math.sqrt dataPiece.avgSalary / Math.PI / 180
      return

    $scope.$watch 'currentDate', -> updateGraph()

    return

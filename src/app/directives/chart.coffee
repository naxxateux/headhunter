app.directive 'chart', ($timeout) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/chart.html'
  scope:
    data: '='
    dates: '='
    currentDate: '='
    zoomRatio: '='
  link: ($scope, $element, $attrs) ->
    d3.selection.prototype.last = -> d3.select @[0][@.size() - 1]

    element = $element[0]
    d3element = d3.select element

    outerWidth = $element.parent().width()
    outerHeight = $element.parent().height()

    padding =
      top: 20
      right: 100
      bottom: 20
      left: 40

    width = outerWidth - padding.left - padding.right
    height = outerHeight - padding.top - padding.bottom

    svg = d3element.append 'svg'
    .classed 'chart__svg', true
    .attr 'width', outerWidth
    .attr 'height', outerHeight

    svg.append 'defs'
    .append 'clipPath'
    .attr 'id', 'clip-rect'
    .append 'rect'
    .attr 'x', 0
    .attr 'y', 0
    .attr 'width', width
    .attr 'height', height

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

    xExtent[1] = xExtent[1] * 1.1 * $scope.zoomRatio
    yExtent[1] = yExtent[1] * 1.1 * $scope.zoomRatio

    x = d3.scale.linear()
    .domain xExtent
    .range [0, width]

    y = d3.scale.linear()
    .domain yExtent
    .range [height, 0]

    color = d3.scale.category20()

    tickFormat = (d) ->
      d * 0.001

    xAxis = d3.svg.axis()
    .scale x
    .orient 'bottom'
    .tickSize 3
    .ticks 5
    .tickFormat tickFormat

    g.append 'g'
    .attr 'class', 'axis x-axis'
    .attr 'transform', 'translate(0, ' + height + ')'
    .call xAxis

    xAxisLastText = d3element.selectAll '.x-axis .tick text'
    .last()
    .text()

    xAxisTitleX = d3element.selectAll '.x-axis .tick text'
    .last()
    .node()
    .getBBox().x

    xAxisTitle = d3element.selectAll '.x-axis .tick'
    .last()
    .append 'text'
    .attr 'x', xAxisTitleX
    .attr 'y', 6
    .attr 'dy', '.71em'

    xAxisTitle.append 'tspan'
    .style 'visibility', 'hidden'
    .text xAxisLastText + ' '

    xAxisTitle.append 'tspan'
    .text 'тыс. вакансий'

    yAxis = d3.svg.axis()
    .scale y
    .orient 'left'
    .tickSize 3
    .ticks 5
    .tickFormat tickFormat

    g.append 'g'
    .attr 'class', 'axis y-axis'
    .call yAxis

    yAxisTitleX = d3element.selectAll '.y-axis .tick text'
    .last()
    .node()
    .getBBox().x

    yAxisTitle = d3element.selectAll '.y-axis .tick'
    .last()
    .append 'text'

    yAxisTitle.append 'tspan'
    .attr 'x', yAxisTitleX
    .attr 'dy', '1.32em'
    .text 'тыс.'

    yAxisTitle.append 'tspan'
    .attr 'x', yAxisTitleX
    .attr 'dy', '1em'
    .text 'резюме'

    jobCVRatios = [20, 10, 6, 5, 4, 3, 2, 1]

    ratiosGroup = g.append 'g'
    .attr 'class', 'ratios'

    jobCVRatios.forEach (ratio) ->
      ratioGroup = ratiosGroup.append 'g'
      .attr 'class', 'ratio'

      nOfJobs = xExtent[1]
      nOfCVs = nOfJobs * ratio
      captionPosition = 'right'

      if nOfCVs > yExtent[1]
        nOfCVs = yExtent[1]
        nOfJobs = nOfCVs / ratio
        captionPosition = 'top'

      ratioGroup.append 'line'
      .attr 'x1', x 0
      .attr 'y1', y 0
      .attr 'x2', x nOfJobs
      .attr 'y2', y nOfCVs
      .style 'stroke', '#333'
      .style 'stroke-width', .1

      ratioGroup.append 'text'
      .attr 'x', x nOfJobs
      .attr 'y', y nOfCVs
      .attr 'dy', if captionPosition is 'right' then '.32em' else '-.32em'
      .attr 'dx', if captionPosition is 'right' then '.32em' else 0
      .style 'font-size', '.9em'
      .style 'fill', '#ccc'
      .text ratio
      return

    industryCirclesGroup = g.append 'g'
    .attr 'class', 'industry-circles'
    .attr 'clip-path', 'url(#clip-rect)'

    _.keys($scope.data).forEach (key) ->
      industryCircleGroup = industryCirclesGroup.append 'g'
      .attr 'class', 'industry-circle'
      .datum $scope.data[key]

      industryCircleGroup.append 'circle'
      .attr 'cx', 0
      .attr 'cy', 0
      .attr 'r', 0
      .style 'fill', color key
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
        Math.sqrt dataPiece.avgSalary / Math.PI / 180 / $scope.zoomRatio
      return

    $scope.$watch 'currentDate', -> updateGraph()

    return

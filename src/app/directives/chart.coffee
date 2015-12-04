app.directive 'chart', ($timeout) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/chart.html'
  scope:
    data: '='
    dates: '='
    currentDate: '='
    colorScale: '='
    zoomRatio: '='
    cloneZoomRatio: '='
    activeIndustries: '='
    hoveredIndustry: '='
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

    tooltip = d3element.select '.chart__tooltip'
    tooltipOffset = 20

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

    xyRatio = Math.ceil yExtent[1] / xExtent[1]

    xExtent[1] = yExtent[1] / xyRatio

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

    industriesGroup = g.append 'g'
    .attr 'class', 'industries'
    .attr 'clip-path', 'url(#clip-rect)'

    _.keys($scope.data).forEach (key) ->
      industryGroup = industriesGroup.append 'g'
      .attr 'class', 'industry'
      .style 'opacity', 1
      .datum $scope.data[key]

      industryGroup.append 'circle'
      .attr 'cx', 0
      .attr 'cy', 0
      .attr 'r', 0
      .style 'fill', $scope.colorScale key
      .style 'opacity', .6
      .on 'mouseover', ->
        d3.select(@).style 'opacity', .7

        tooltip
        .style 'display', 'block'
        .style 'top', d3.event.pageY + 'px'
        .style 'left', d3.event.pageX + tooltipOffset + 'px'
        .html key
        return
      .on 'mousemove', ->
        tooltip
        .style 'top', d3.event.pageY + 'px'
        .style 'left', d3.event.pageX + tooltipOffset + 'px'
        return
      .on 'mouseout', ->
        d3.select(@).style 'opacity', .6

        tooltip.style 'display', ''
        return

      industryGroup.append 'path'
      .style 'fill', 'none'
      .style 'stroke', $scope.colorScale key
      .style 'stroke-opacity', .5
      .style 'stroke-width', 2
      .style 'stroke-linecap', 'round'
      .style 'stroke-linejoin', 'round'
      return

    jobCVRatios = [20, 10, 7, 5, 4, 3, 2, 1]

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

    if $scope.zoomRatio is 1
      zoneData = [
        [0, y(yExtent[1] * $scope.cloneZoomRatio)]
        [x(xExtent[1] * $scope.cloneZoomRatio), y(yExtent[1] * $scope.cloneZoomRatio)]
        [x(xExtent[1] * $scope.cloneZoomRatio), height]
      ]

      g.append 'path'
      .datum zoneData
      .attr 'class', 'zone'
      .attr 'd', d3.svg.line()
      .style 'fill', 'none'
      .style 'stroke', '#333'
      .style 'stroke-width', .1
      .style 'stroke-dasharray', '3, 3'

    getDataPiece = (data) -> _.find data, {'date': $scope.currentDate}

    getDataPiecesBeforeDate = (data) ->
      dataIndex = _.findIndex data, {'date': $scope.currentDate}
      data.slice 0, dataIndex + 1

    line = d3.svg.line()
    .x (d) -> x d.nOfJobs
    .y (d) -> y d.nOfCVs
    .interpolate 'linear'

    updateGraph = ->
      console.log 'Graph updated → Date: ' + $scope.currentDate.moment.format('MMMM YYYY')

      industriesGroup.selectAll '.industry'
      .select 'circle'
      .transition()
      .duration 180
      .attr 'cx', (data) -> x getDataPiece(data).nOfJobs
      .attr 'cy', (data) -> y getDataPiece(data).nOfCVs
      .attr 'r', (data) -> Math.sqrt getDataPiece(data).avgSalary / Math.PI / 180

      industriesGroup.selectAll '.industry'
      .select 'path'
      .transition()
      .duration 180
      .attr 'd', (data) ->
        dataPieces = getDataPiecesBeforeDate data

        if dataPieces.length > 1
          line dataPieces
        else ''
      return

    updateIndustriesActivity = ->
      console.log 'Graph updated → Industries: ' + $scope.activeIndustries

      unless $scope.activeIndustries.length
        industriesGroup.selectAll '.industry'
        .transition()
        .duration 90
        .style 'opacity', 1
      else
        industriesGroup.selectAll '.industry'
        .transition()
        .duration 90
        .style 'opacity', (d) ->
          if $scope.activeIndustries.indexOf(d.$key) is -1 then 0 else 1
      return

    updateIndustriesVisibility = ->
      console.log 'Graph updated → Industry: ' + $scope.hoveredIndustry
      unless $scope.activeIndustries.length
        industriesGroup.selectAll '.industry'
        .transition()
        .duration 90
        .style 'opacity', (d) ->
          if $scope.hoveredIndustry
            if d.$key is $scope.hoveredIndustry then 1 else .15
          else
            1
      else
        industriesGroup.selectAll '.industry'
        .transition()
        .duration 90
        .style 'opacity', (d) ->
          if $scope.hoveredIndustry
            if $scope.activeIndustries.indexOf(d.$key) is -1
              if d.$key is $scope.hoveredIndustry then .15 else 0
            else
              1
          else
            if $scope.activeIndustries.indexOf(d.$key) is -1 then 0 else 1
      return

    $scope.$watch 'currentDate', -> updateGraph()

    $scope.$watch 'activeIndustries', (-> updateIndustriesActivity()), true

    $scope.$watch 'hoveredIndustry', -> updateIndustriesVisibility()

    return

app.directive 'chart', ($timeout) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/chart.html'
  scope:
    data: '='
    dates: '='
    model: '='
    colorScale: '='
    zoomRatio: '='
    cloneZoomRatio: '='
    monthNames: '='
  link: ($scope, $element, $attrs) ->
    d3.selection.prototype.last = -> d3.select @[0][@.size() - 1]

    getDataPiece = (data, date) ->
      unless date
        _.find data, {'date': $scope.model.currentDate}
      else
        _.find data, {'date': date}

    getDataPiecesBeforeDate = (data) ->
      dataIndex = _.findIndex data, {'date': $scope.model.currentDate}
      data.slice 0, dataIndex + 1

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
      if d then d * .001 else ''

    xAxis = d3.svg.axis()
    .scale x
    .orient 'bottom'
    .tickSize 0
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
    .attr 'y', 3
    .attr 'dy', '.71em'

    xAxisTitle.append 'tspan'
    .style 'visibility', 'hidden'
    .text xAxisLastText + ' '

    xAxisTitle.append 'tspan'
    .text 'тыс. вакансий'

    yAxis = d3.svg.axis()
    .scale y
    .orient 'left'
    .tickSize 0
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

    g.append 'text'
    .attr 'class', 'joint-zero'
    .attr 'x', -3
    .attr 'y', height + 3
    .attr 'dy', '.71em'
    .style 'text-anchor', 'end'
    .text '0'

    dateCaption = g.append 'text'
    .attr 'class', 'date-caption'
    .attr 'x', width
    .attr 'y', height - 20
    .style 'text-anchor', 'end'

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
      .style 'opacity', .7
      .on 'mouseover', ->
        d3.select(@).style 'opacity', .8

        tooltip
        .style 'display', 'block'
        .style 'top', d3.event.pageY + 'px'
        .style 'left', d3.event.pageX + tooltipOffset + 'px'
        .html ->
          avgSalary = getDataPiece($scope.data[key]).avgSalary

          key + if avgSalary isnt 1000 then (', ' + (avgSalary * .001).toFixed() + ' тыс. руб.') else ''
        return
      .on 'mousemove', ->
        tooltip
        .style 'top', d3.event.pageY + 'px'
        .style 'left', d3.event.pageX + tooltipOffset + 'px'
        return
      .on 'mouseout', ->
        d3.select(@).style 'opacity', .7

        tooltip.style 'display', ''
        return

      industryGroup.append 'path'
      .style 'fill', 'none'
      .style 'stroke', $scope.colorScale key
      .style 'stroke-opacity', .5
      .style 'stroke-width', 2
      .style 'stroke-linecap', 'round'
      .style 'stroke-linejoin', 'round'

      salaryHistory = industryGroup.append 'g'
      .attr 'class', 'salary-history'
      .style 'opacity', 1

      $scope.dates.forEach (date) ->
        salaryHistory.append 'circle'
        .datum date
        .attr 'cx', x getDataPiece($scope.data[key], date).nOfJobs
        .attr 'cy', y getDataPiece($scope.data[key], date).nOfCVs
        .attr 'r', (data) -> Math.sqrt getDataPiece($scope.data[key], date).avgSalary / Math.PI / 180
        .style 'fill', $scope.colorScale key
        .style 'opacity', .7
        .style 'visibility', 'hidden'
        return
      return

    jobCVRatios = [20, 10, 7, 5, 4, 3, 2, 1]

    ratiosGroup = g.append 'g'
    .attr 'class', 'ratios'
    .style 'opacity', 1

    jobCVRatios.forEach (ratio, i) ->
      ratioGroup = ratiosGroup.append 'g'
      .attr 'class', 'ratio'

      nOfJobs = xExtent[1]
      nOfCVs = nOfJobs * ratio
      captionPosition = 'right'

      if nOfCVs is yExtent[1]
        captionPosition = 'top-corner'
      else if nOfCVs > yExtent[1]
        captionPosition = 'top'

      if nOfCVs > yExtent[1]
        nOfCVs = yExtent[1]
        nOfJobs = nOfCVs / ratio

      ratioGroup.append 'line'
      .attr 'x1', x 0
      .attr 'y1', y 0
      .attr 'x2', x nOfJobs
      .attr 'y2', y nOfCVs
      .style 'stroke', '#bbb'
      .style 'stroke-width', .5

      unless i
        ratioCaption = ratioGroup.append 'text'
        .style 'fill', '#bbb'
        .style 'font-size', '.9em'

        ratioCaption.append 'tspan'
        .attr 'x', x nOfJobs
        .attr 'dx', '.32em'
        .attr 'dy', '-.32em'
        .text ratio + ' резюме'

        ratioCaption.append 'tspan'
        .attr 'x', x nOfJobs
        .attr 'dx', '.32em'
        .attr 'dy', '1em'
        .text 'на вакансию'
      else
        ratioGroup.append 'text'
        .attr 'x', x nOfJobs
        .attr 'y', y nOfCVs
        .attr 'dy', ->
          if captionPosition is 'top' or captionPosition is 'top-corner'
            '-.32em'
          else
            '.32em'
        .attr 'dx', ->
          if captionPosition is 'right' or captionPosition is 'top-corner'
            '.32em'
          else
            0
        .style 'fill', '#bbb'
        .style 'font-size', '.9em'
        .text ratio
      return

    if $scope.zoomRatio is 1
      g.append 'rect'
      .attr 'class', 'zone'
      .attr 'x', 0
      .attr 'y', y yExtent[1] * $scope.cloneZoomRatio
      .attr 'width', x xExtent[1] * $scope.cloneZoomRatio
      .attr 'height', height - y yExtent[1] * $scope.cloneZoomRatio
      .style 'fill', 'none'
      .style 'stroke', '#999'
      .style 'stroke-width', .5
      .style 'stroke-dasharray', '3, 3'

    line = d3.svg.line()
    .x (d) -> x d.nOfJobs
    .y (d) -> y d.nOfCVs
    .interpolate 'linear'

    updateGraph = ->
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

      industriesGroup.selectAll '.industry'
      .select '.salary-history'
      .selectAll 'circle'
      .style 'visibility', (d) -> if $scope.model.currentDate.moment.diff(d.moment, 'days') > 0 then 'visible' else 'hidden'

      if $scope.zoomRatio is 1
        dateCaption.text $scope.monthNames[$scope.model.currentDate.moment.month()].full + ' ' + $scope.model.currentDate.moment.year()
      return

    updateIndustriesActivity = ->
      unless $scope.model.activeIndustries.length
        industriesGroup.selectAll '.industry'
        .transition()
        .duration 90
        .style 'opacity', 1
      else
        industriesGroup.selectAll '.industry'
        .transition()
        .duration 90
        .style 'opacity', (d) ->
          if $scope.model.activeIndustries.indexOf(d.$key) is -1 then 0 else 1
      return

    updateIndustriesVisibility = ->
      unless $scope.model.activeIndustries.length
        industriesGroup.selectAll '.industry'
        .transition()
        .duration 90
        .style 'opacity', (d) ->
          if $scope.model.hoveredIndustry
            if d.$key is $scope.model.hoveredIndustry then 1 else .15
          else
            1
      else
        industriesGroup.selectAll '.industry'
        .transition()
        .duration 90
        .style 'opacity', (d) ->
          if $scope.model.hoveredIndustry
            if $scope.model.activeIndustries.indexOf(d.$key) is -1
              if d.$key is $scope.model.hoveredIndustry then .15 else 0
            else
              1
          else
            if $scope.model.activeIndustries.indexOf(d.$key) is -1 then 0 else 1
      return

    updateIndustryPathsVisibility = ->
      industriesGroup.selectAll '.industry'
      .select 'path'
      .transition()
      .duration 90
      .style 'stroke-opacity', if $scope.model.showIndustryPaths then .5 else 0
      return

    updateRatiosVisibility = ->
      ratiosGroup
      .transition()
      .duration 90
      .style 'opacity', if $scope.model.showRatios then 1 else 0
      return

    updateSalaryHistoryVisibility = ->
      industriesGroup.selectAll '.industry'
      .select '.salary-history'
      .transition()
      .duration 90
      .style 'opacity', if $scope.model.showSalaryHistory then 1 else 0
      return

    $scope.$watch 'model.currentDate', -> updateGraph()

    $scope.$watch 'model.activeIndustries', (-> updateIndustriesActivity()), true

    $scope.$watch 'model.hoveredIndustry', -> updateIndustriesVisibility()

    $scope.$watch 'model.showIndustryPaths', -> updateIndustryPathsVisibility()

    $scope.$watch 'model.showRatios', -> updateRatiosVisibility()

    $scope.$watch 'model.showSalaryHistory', -> updateSalaryHistoryVisibility()

    return

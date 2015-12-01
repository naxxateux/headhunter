app.directive 'chart', ($timeout) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/chart.html'
  scope:
    data: '='
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

    return

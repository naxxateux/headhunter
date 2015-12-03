app.directive 'playButton', ($document) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/play-button.html'
  scope:
    dates: '='
    currentDate: '='
  link: ($scope, $element, $attrs) ->
    return

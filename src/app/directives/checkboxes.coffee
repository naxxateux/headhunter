app.directive 'checkboxes', ($document) ->
  restrict: 'E'
  replace: true
  templateUrl: 'templates/directives/checkboxes.html'
  scope:
    model: '='
  link: ($scope, $element, $attrs) ->
    return

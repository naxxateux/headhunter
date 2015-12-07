app.controller 'mainCtrl', ($scope) ->
  dateFormat = 'M/D/YYYY'

  $scope.monthNames = [
    {full: 'январь', short: 'янв'},
    {full: 'февраль', short: 'фев'},
    {full: 'март', short: 'мар'},
    {full: 'апрель', short: 'апр'},
    {full: 'май', short: 'май'},
    {full: 'июнь', short: 'июнь'},
    {full: 'июль', short: 'июль'},
    {full: 'август', short: 'авг'},
    {full: 'сентябрь', short: 'сен'},
    {full: 'октябрь', short: 'окт'},
    {full: 'ноябрь', short: 'ноя'},
    {full: 'декабрь', short: 'дек'}
  ]

  colors = [
    '#1f77b4'
    '#17becf'
    '#ff7f0e'
    '#2ca02c'
    '#d62728'
    '#9467bd'
    '#8c564b'
    '#e377c2'
    '#7f7f7f'
    '#bcbd22'
    '#aec7e8'
    '#ffbb78'
    '#c5b0d5'
    '#c7c7c7'
    '#ff9896'
  ]

  neutralColor = '#666'

  industryColors = {}

  $scope.colorScale = (industry) -> industryColors[industry]

  $scope.isDataPrepared = false

  $scope.data = {}
  $scope.dates = []

  $scope.model =
    currentDate: undefined
    activeIndustries: []
    hoveredIndustry: ''
    showIndustryPaths: true
    showRatios: true
    showSalaryHistory: false

  # Parse main data
  parseMainData = (error, rawData) ->
    if error
      console.log error

    rawData = rawData[0].concat rawData[1]

    industries = _.uniq _.pluck rawData, 'Проф.область'
    _.remove industries, (industry) -> industry is 'Все сферы'

    $scope.dates = _.keys rawData[0]
    .filter (key) ->
      key isnt 'Москва' and key isnt 'Проф.область'
    .map (key) ->
      raw: key
      moment: moment key, dateFormat

    $scope.model.currentDate = $scope.dates[0]

    industries.forEach (industry) ->
      industryData = rawData.filter (rD) -> rD['Проф.область'] is industry
      $scope.data[industry] = []

      $scope.dates.forEach (date) ->
        dataPiece = {}

        nOfJobs = parseInt _.find(industryData, {'Москва': 'Кол-во вакансий, средняя за день, шт.'})[date.raw].replace(',', '')
        nOfCVs = parseInt _.find(industryData, {'Москва': 'Кол-во резюме, средняя за день, шт.'})[date.raw].replace(',', '')
        hhIndex = parseFloat _.find(industryData, {'Москва': 'hh.индекс - уровень конкуренции'})[date.raw]
        nOfResponses = parseInt _.find(industryData, {'Москва': 'Количество откликов на одну вакансию, шт.'})[date.raw]

        if _.find(industryData, {'Москва': 'Средняя предлагаемая зарплата, руб.'})
          avgSalary = parseInt _.find(industryData, {'Москва': 'Средняя предлагаемая зарплата, руб.'})[date.raw].replace(',', '')
        else
          avgSalary = 1000

        dataPiece.date = date
        dataPiece.nOfJobs = nOfJobs
        dataPiece.nOfCVs = nOfCVs
        dataPiece.hhIndex = hhIndex
        dataPiece.nOfResponces = nOfResponses
        dataPiece.avgSalary = avgSalary

        $scope.data[industry].push dataPiece
        return
      return

    _.keys $scope.data
    .sort (a, b) ->
      a = _.find($scope.data[a], {'date': $scope.dates[$scope.dates.length - 1]}).avgSalary
      b = _.find($scope.data[b], {'date': $scope.dates[$scope.dates.length - 1]}).avgSalary
      b - a
    .forEach (industry, i) ->
      if i < colors.length
        industryColors[industry] = colors[i]
      else
        industryColors[industry] = neutralColor
      return

    $scope.isDataPrepared = true

    $scope.$apply()

    $('.loading-cover').fadeOut()
    return

  # Load main data
  queue()
  .defer d3.csv, '../data/data1.csv'
  .defer d3.csv, '../data/data2.csv'
  .awaitAll parseMainData

  return

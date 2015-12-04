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
    '#3dac65'
    '#a54cae'
    '#e4447c'
    '#3b9685'
    '#f66768'
    '#d78a2e'
    '#da4043'
    '#5a7ddc'
    '#7867a0'
    '#67a127'
    '#a78045'
    '#ee6c19'
    '#3780fa'
    '#43b85d'
    '#e43c8f'
    '#2b7a9a'
    '#b2881a'
    '#e44f65'
    '#d07f84'
    '#0fad99'
    '#6e92ba'
    '#a794ca'
    '#4ba627'
    '#e57a5a'
    '#48a161'
    '#2570c0'
    '#12a9e3'
    '#809924'
  ]

  $scope.colorScale = d3.scale.ordinal()
  .range colors

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

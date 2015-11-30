app.controller 'mainCtrl', ($scope) ->
  dateFormat = 'M/D/YYYY'

  $scope.isDataPrepared = false

  $scope.data = {}
  $scope.dates = []

  # Parse main data
  parseMainData = (error, rawData) ->
    if error
      console.log error

    rawData = rawData[0].concat rawData[1]
    industries = _.uniq _.pluck rawData, 'Проф.область'
    $scope.dates = _.keys rawData[0]
    .filter (key) ->
      key isnt 'Москва' and key isnt 'Проф.область'
    .map (key) ->
      raw: key
      moment: moment key, dateFormat

    industries.forEach (industry) ->
      industryData = rawData.filter (rD) -> rD['Проф.область'] is industry
      $scope.data[industry] = []

      $scope.dates.forEach (date) ->
        dataPiece =
          date: date.moment.toDate()

        nOfJobs = parseInt _.find(industryData, {'Москва': 'Кол-во вакансий, средняя за день, шт.'})[date.raw].replace(',', '')
        nOfCVs = parseInt _.find(industryData, {'Москва': 'Кол-во резюме, средняя за день, шт.'})[date.raw].replace(',', '')
        hhIndex = parseFloat _.find(industryData, {'Москва': 'hh.индекс - уровень конкуренции'})[date.raw]
        nOfResponses = parseInt _.find(industryData, {'Москва': 'Количество откликов на одну вакансию, шт.'})[date.raw]

        if _.find(industryData, {'Москва': 'Средняя предлагаемая зарплата, руб.'})
          avgSalary = parseInt _.find(industryData, {'Москва': 'Средняя предлагаемая зарплата, руб.'})[date.raw].replace(',', '')
        else
          avgSalary = 30000

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

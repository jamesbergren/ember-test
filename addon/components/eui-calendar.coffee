`import className from '../mixins/class-name'`

calendar = Em.Component.extend className,
  tagName: 'eui-calendar'

  baseClass: 'calendar'
  style: 'default'

  showNextMonth:       true
  showPrevMonth:       false

  disabledDates:       null
  disablePast:         null
  disableFuture:       null

  maxPastDate:         null
  maxFutureDate:       null

  month:               null

  allowMultiple:       false
  continuousSelection: true
  _selection:          []

  setup: (->
    Ember.warn(
      'EUI-CALENDAR: You have passed in multiple dates without allowing for mulitple date _selection',
      !(@get('_selection.length') > 1 && !@get('allowMultiple'))
    )

    firstSelectedDate = @get '_selection.firstObject'

    if not @get('month') and firstSelectedDate
      @set 'month', firstSelectedDate.clone().startOf('month')

    unless @get 'month'
      @set 'month', moment().startOf('month')
  ).on 'init'

  actions:
    dateSelected: (date) ->
      if @get 'allowMultiple'
        if @get 'continuousSelection'

          # User is finishing a selection
          if @get('_selection.length') is 1

            # If user clicked same date as the first one they probably mean to restart their selection
            if date.isSame @get '_selection.firstObject'
              @set '_selection', []
            else
              @addDateRange @get('_selection.firstObject'), date

          # User is starting a new selection
          else
            @set '_selection', [date]

        else
          if @hasDate(date)
            @removeDate(date)
          else
            @addDate(date)

      else
        if @hasDate(date)
          @set '_selection', []
        else
          @set '_selection', [date]

      # Delay sending action until after the selection has been updated

      Ember.run.next @, -> @sendAction('selectAction', date)


    prev: ->
      month = @get 'month'

      if !month || @get 'isPrevDisabled'
        return

      @set 'month', month.clone().subtract(1, 'months')


    next: ->
      month = @get 'month'

      if !month || @get 'isNextDisabled'
        return

      @set 'month', month.clone().add(1, 'months')


  selection: Ember.computed '_selection',
    get: (key) ->
      selection = @get('_selection')

      if @get 'allowMultiple'
        return selection

      else
        return selection.get('firstObject')

    set: (key, value) ->
      if Ember.isArray(value)
        @set '_selection', value
      else if value
        @set '_selection', [value]
      else
        @set '_selection', []

      value


  hasDate: (date) ->
    return @get('_selection').any (d) ->
      return d.isSame(date)


  isDisabledDate: (date) ->
    disabledDates = @get 'disabledDates'

    return unless disabledDates

    return disabledDates.any (d) ->
      return d.isSame(date)


  removeDate: (date) ->
    dates = @get '_selection'

    removeDates = dates.filter (d) ->
      return d.isSame(date)

    dates.removeObjects(removeDates)


  addDate: (date) ->
    @removeDate date
    @get('_selection').pushObject(date)


  addDateRange: (startDate, endDate) ->
    day = moment(startDate)
    newSelection = [startDate]

    # User clicked on a day BEFORE the current selected day
    if endDate.isBefore startDate
      day.subtract 1, 'days'

      while not day.isBefore endDate
        newSelection.pushObject(moment day) unless @isDisabledDate(moment day)
        day.subtract 1, 'days'

    # User clicked on a day AFTER the current selected day
    else
      day.add 1, 'days'

      while not day.isAfter endDate
        newSelection.pushObject(moment day) unless @isDisabledDate(moment day)
        day.add 1, 'days'

    @set 'selection', newSelection

  # TODO: Add timer to invalidate this
  now: (->
    return moment()
  ).property()


  prevMonth: (->
    month = @get 'month'
    return if month then month.clone().subtract(1, 'months') else null
  ).property 'month'


  nextMonth: (->
    month = @get 'month'
    return if month then month.clone().add(1, 'months') else null
  ).property 'month'


  isNextMonthInFuture: (->
    nextMonth = @get 'nextMonth'
    now = @get 'now'

    return if nextMonth then nextMonth.isAfter(now, 'month') else false
  ).property 'nextMonth', 'now'


  isPrevMonthInPast: (->
    prevMonth = @get 'prevMonth'
    now = @get 'now'

    return if prevMonth then prevMonth.isBefore(now, 'month') else false
  ).property 'prevMonth', 'now'


  isPrevMonthBeyondMax: (->
    prevMonth = @get 'prevMonth'
    maxPastDate = @get 'maxPastDate'

    if not prevMonth || not maxPastDate
      return false

    return prevMonth.isBefore(maxPastDate, 'month')
  ).property 'prevMonth', 'maxPastDate'


  isNextMonthBeyondMax: (->
    nextMonth = @get 'nextMonth'
    maxFutureDate = @get 'maxFutureDate'

    if not nextMonth || not maxFutureDate
      return false

    return nextMonth.isAfter(maxFutureDate, 'month')
  ).property 'nextMonth', 'maxFutureDate'


  isPrevDisabled: (->
    if @get 'isPrevMonthBeyondMax'
      return true

    if @get('disablePast') and @get('isPrevMonthInPast')
      return true

    return false
  ).property 'isPrevMonthBeyondMax', 'isPrevMonthInPast', 'disablePast'


  isNextDisabled: (->
    if @get 'isNextMonthBeyondMax'
      return true

    if @get('disableFuture') and @get('isNextMonthInFuture')
      return true

    return false
  ).property 'isNextMonthBeyondMax', 'isNextMonthInFuture', 'disableFuture'

  prevMonthLabel: Em.computed 'prevMonth', ->
    return  @get('prevMonth').format('MMMM YYYY')

  nextMonthLabel: Em.computed 'nextMonth', ->
    return  @get('nextMonth').format('MMMM YYYY')

  monthLabel: Em.computed 'month', ->
    return  @get('month').format('MMMM YYYY')


` export default calendar`

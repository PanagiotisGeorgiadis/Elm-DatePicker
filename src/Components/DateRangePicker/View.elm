module Components.DateRangePicker.View exposing (view)

import Clock
import Components.DateRangePicker.Update
    exposing
        ( DateLimit(..)
        , DateRange(..)
        , DateRangeOffset(..)
        , InternalViewType(..)
        , Model
        , Msg(..)
        , SelectionType(..)
        , TimePickerState(..)
        , ViewType(..)
        )
import Components.MonthPicker as MonthPicker
import Components.TimePicker.Update as TimePicker
import Components.TimePicker.View as TimePicker
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Icons
import Utils.DateTime exposing (getMonthInt)
import Utils.Maybe as Maybe
import Utils.Time as Time


view : Model -> Html Msg
view ({ viewType, internalViewType } as model) =
    div [ class "date-range-picker" ]
        (case ( viewType, internalViewType ) of
            ( Single, _ ) ->
                [ singleCalendarView model
                , case model.range of
                    BothSelected (Chosen _ _) ->
                        doubleClockView model

                    _ ->
                        text ""
                ]

            ( Double, CalendarView ) ->
                [ doubleCalendarView model
                ]

            ( Double, ClockView ) ->
                [ doubleClockView model
                ]
        )


singleCalendarView : Model -> Html Msg
singleCalendarView ({ primaryDate, dateLimit } as model) =
    let
        ( isPreviousButtonActive, isNextButtonActive ) =
            case dateLimit of
                DateLimit { minDate, maxDate } ->
                    let
                        primaryDateMonthInt =
                            getMonthInt primaryDate
                    in
                    ( getMonthInt minDate < primaryDateMonthInt
                    , getMonthInt maxDate > primaryDateMonthInt
                    )

                NoLimit _ ->
                    ( True
                    , True
                    )

        pickerConfig =
            { date = primaryDate
            , nextButtonHandler = getNextButtonAction isNextButtonActive
            , previousButtonHandler = getPreviousButtonAction isPreviousButtonActive
            }
    in
    div
        [ class "single-calendar-view no-select"
        , onMouseLeave ResetVisualSelection
        ]
        [ MonthPicker.singleMonthPickerView2 pickerConfig
        , calendarView model
        , todayButtonHtml model
        ]


doubleCalendarView : Model -> Html Msg
doubleCalendarView ({ primaryDate, dateLimit } as model) =
    let
        nextDate =
            DateTime.incrementMonth primaryDate

        ( isPreviousButtonActive, isNextButtonActive ) =
            case dateLimit of
                DateLimit { minDate, maxDate } ->
                    ( getMonthInt minDate < getMonthInt primaryDate
                    , getMonthInt maxDate > getMonthInt nextDate
                    )

                NoLimit _ ->
                    ( True
                    , True
                    )

        pickerConfig =
            { date = primaryDate
            , nextButtonHandler = getNextButtonAction isNextButtonActive
            , previousButtonHandler = getPreviousButtonAction isPreviousButtonActive
            }

        nextModel =
            { model | primaryDate = nextDate }
    in
    div
        [ class "double-calendar-view no-select"
        , onMouseLeave ResetVisualSelection
        ]
        [ MonthPicker.doubleMonthPickerView2 pickerConfig
        , calendarView model
        , calendarView nextModel
        , todayButtonHtml model
        , case model.range of
            BothSelected (Chosen _ _) ->
                div [ class "switch-view-button", onClick ShowClockView ] [ Icons.chevron Icons.Right (Icons.Size "20" "20") ]

            _ ->
                div [ class "switch-view-button disabled" ] [ Icons.chevron Icons.Right (Icons.Size "20" "20") ]
        ]


doubleClockView : Model -> Html Msg
doubleClockView { range, timePickers, viewType } =
    case timePickers of
        TimePickers { startPicker, endPicker, mirrorTimes } ->
            let
                displayDateHtml date =
                    case date of
                        Just d ->
                            span [ class "date" ] [ text (Time.toHumanReadableDateTime d) ]

                        Nothing ->
                            text ""

                ( rangeStart, rangeEnd ) =
                    case range of
                        BothSelected (Chosen start end) ->
                            ( Just start, Just end )

                        _ ->
                            ( Nothing, Nothing )

                pickerTypeString =
                    case viewType of
                        Single ->
                            TimePicker.getPickerTypeString startPicker

                        Double ->
                            ""
            in
            div [ class ("double-clock-view " ++ pickerTypeString) ]
                [ div [ class "time-picker-container no-select" ]
                    [ span [ class "header" ] [ text "Pick-up Time" ]
                    , displayDateHtml rangeStart
                    , Html.map RangeStartPickerMsg (TimePicker.view startPicker)
                    , div [ class "checkbox", onClick ToggleTimeMirroring ]
                        [ Icons.checkbox (Icons.Size "16" "16") mirrorTimes
                        , span [ class "text" ] [ text "Same as drop-off time" ]
                        ]
                    ]
                , div [ class "time-picker-container no-select" ]
                    [ span [ class "header" ] [ text "Drop-off Time" ]
                    , displayDateHtml rangeEnd
                    , Html.map RangeEndPickerMsg (TimePicker.view endPicker)
                    , div [ class "filler" ] []
                    ]
                , case viewType of
                    Single ->
                        text ""

                    Double ->
                        div [ class "switch-view-button", onClick ShowCalendarView ] [ Icons.chevron Icons.Left (Icons.Size "20" "20") ]
                ]

        _ ->
            text ""


calendarView : Model -> Html Msg
calendarView ({ primaryDate } as model) =
    let
        monthDates =
            List.map (DateTime.setTime Clock.midnight) (DateTime.getDatesInMonth primaryDate)

        datesHtml =
            List.map (dateHtml model) monthDates

        precedingWeekdaysCount =
            case getFirstDayOfTheMonth primaryDate of
                Just firstDayOfTheMonth ->
                    Time.precedingWeekdays (DateTime.getWeekday firstDayOfTheMonth)

                Nothing ->
                    0

        precedingDatesHtml =
            List.repeat precedingWeekdaysCount emptyDateHtml

        followingDates =
            totalCalendarCells - precedingWeekdaysCount - List.length monthDates

        followingDatesHtml =
            List.repeat followingDates emptyDateHtml
    in
    div [ class "calendar" ]
        [ weekdaysHtml
        , div [ class "calendar_" ]
            (precedingDatesHtml ++ datesHtml ++ followingDatesHtml)
        ]


dateHtml : Model -> DateTime -> Html Msg
dateHtml model date =
    let
        isDisabled =
            checkIfDisabled model date

        isInvalid =
            checkIfInvalid model date

        isEqualToDate date_ =
            DateTime.compareDates date date_ == EQ

        isGreaterThanDate date_ =
            DateTime.compareDates date date_ == GT

        isLesserThanDate date_ =
            DateTime.compareDates date date_ == LT

        isToday =
            isEqualToDate model.today

        isPartOfTheDateRange =
            let
                isDateBetween start end =
                    (isGreaterThanDate start && isLesserThanDate end)
                        || (isLesserThanDate start && isGreaterThanDate end)
            in
            case model.range of
                BothSelected (Visually start shadowEnd) ->
                    isDateBetween start shadowEnd

                BothSelected (Chosen start end) ->
                    isDateBetween start end

                _ ->
                    False
    in
    if isDisabled || isInvalid then
        span
            [ classList
                [ ( "date", True )
                , ( "today", isToday )
                , ( "disabled", isDisabled )
                , ( "invalid", isInvalid )
                , ( "date-range", isPartOfTheDateRange )
                ]
            , title (Time.toHumanReadableDate date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]

    else
        let
            ( isStart, isEnd ) =
                case model.range of
                    BothSelected (Visually start end) ->
                        let
                            -- The visual dates are not always sorted.
                            -- This is the reason why we have to do this "sort" here.
                            ( start_, end_ ) =
                                case DateTime.compareDates start end of
                                    LT ->
                                        ( start, end )

                                    _ ->
                                        ( end, start )
                        in
                        if isEqualToDate start_ then
                            ( True, False )

                        else if isEqualToDate end_ then
                            ( False, True )

                        else
                            ( False, False )

                    BothSelected (Chosen start end) ->
                        ( isEqualToDate start, isEqualToDate end )

                    _ ->
                        ( False, False )

            isSelected =
                case model.range of
                    StartDateSelected start ->
                        isEqualToDate start

                    _ ->
                        False

            dateClassList =
                [ ( "date", True )
                , ( "today", isToday )
                , ( "selected", isSelected || isStart || isEnd )
                , ( "date-range", isPartOfTheDateRange )
                , ( "date-range-start", isStart )
                , ( "date-range-end", isEnd )
                ]
        in
        span
            [ classList dateClassList
            , title (Time.toHumanReadableDate date)
            , onClick (SelectDate date)
            , onMouseOver (UpdateVisualSelection date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]



-- getMonthPickerHtml : Model2 -> Html Msg
-- getMonthPickerHtml m =
--     case m of
--         Constrained_ { minDate, maxDate } { primaryDate, viewType } ->
--             let
--                 ( primaryDateMonthInt, nextDateMonthInt ) =
--                     ( DateTime.getMonth primaryDate
--                     , DateTime.getMonth (DateTime.incrementMonth primaryDate)
--                     )
--
--                 getPickerConfig futureMonthInt =
--                     { date = primaryDate
--                     , nextButtonHandler = getNextButtonAction (DateTime.getMonth maxDate > futureMonthInt)
--                     , previousButtonHandler = getPreviousButtonAction (DateTime.getMonth minDate < primaryDateMonthInt)
--                     }
--             in
--             case viewType of
--                 Single ->
--                     MonthPicker.singleMonthPickerView2 (getPickerConfig primaryDateMonthInt)
--
--                 Double ->
--                     MonthPicker.doubleMonthPickerView2 (getPickerConfig nextDateMonthInt)
--
--         Unconstrained_ { today, viewType, primaryDate, pastDatesLimit, futureDatesLimit } ->
--             let
--                 getPickerConfig nextButtonDate =
--                     { date = primaryDate
--                     , nextButtonHandler = getNextButtonAction (isBetweenFutureLimit today nextButtonDate futureDatesLimit)
--                     , previousButtonHandler = getPreviousButtonAction (isBetweenPastLimit today (DateTime.decrementMonth primaryDate) pastDatesLimit)
--                     }
--             in
--             case viewType of
--                 Single ->
--                     MonthPicker.singleMonthPickerView2 (getPickerConfig primaryDate)
--
--                 Double ->
--                     MonthPicker.doubleMonthPickerView2 (getPickerConfig (DateTime.incrementMonth primaryDate))


getNextButtonAction : Bool -> Maybe Msg
getNextButtonAction isButtonActive =
    if isButtonActive then
        Just NextMonth

    else
        Nothing


getPreviousButtonAction : Bool -> Maybe Msg
getPreviousButtonAction isButtonActive =
    if isButtonActive then
        Just PreviousMonth

    else
        Nothing


checkIfDisabled : Model -> DateTime -> Bool
checkIfDisabled { today, dateLimit } date =
    let
        isGreaterThanDate date_ =
            DateTime.compareDates date date_ == GT

        isLesserThanDate date_ =
            DateTime.compareDates date date_ == LT

        isEqualToDate date_ =
            DateTime.compareDates date date_ == EQ
    in
    case dateLimit of
        NoLimit { disablePastDates } ->
            let
                isPastDate =
                    isLesserThanDate today
            in
            disablePastDates && isPastDate

        DateLimit { minDate, maxDate } ->
            isLesserThanDate minDate || isGreaterThanDate maxDate


checkIfInvalid : Model -> DateTime -> Bool
checkIfInvalid { dateRangeOffset } date =
    case dateRangeOffset of
        Offset { invalidDates } ->
            List.any ((==) date) invalidDates

        NoOffset ->
            False


{-| Extract to another file as a common view fragment
-}
getFirstDayOfTheMonth : DateTime -> Maybe DateTime
getFirstDayOfTheMonth date =
    DateTime.fromRawParts
        { day = 1
        , month = DateTime.getMonth date
        , year = DateTime.getYear date
        }
        { hours = 0
        , minutes = 0
        , seconds = 0
        , milliseconds = 0
        }


{-| Extract to another file as a common view fragment
-}
weekdaysHtml : Html Msg
weekdaysHtml =
    div [ class "weekdays" ]
        [ span [] [ text "Su" ]
        , span [] [ text "Mo" ]
        , span [] [ text "Tu" ]
        , span [] [ text "We" ]
        , span [] [ text "Th" ]
        , span [] [ text "Fr" ]
        , span [] [ text "Sa" ]
        ]


{-| Extract to another file as a common view fragment
-}
emptyDateHtml : Html Msg
emptyDateHtml =
    span [ class "empty-date" ] []


{-| Extract to another file as a common view fragment

6 rows in total on the calendar
7 columns on the calendar
6 \* 7 = 42 is the total count of cells.

-}
totalCalendarCells : Int
totalCalendarCells =
    6 * 7


todayButtonHtml : Model -> Html Msg
todayButtonHtml { viewType } =
    div
        [ classList
            [ ( "today-button", True )
            , ( "align-left", viewType == Single )
            ]
        , onClick MoveToToday
        ]
        [ text "Today"
        ]

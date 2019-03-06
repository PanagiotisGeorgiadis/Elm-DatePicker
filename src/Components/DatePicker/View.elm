module Components.DatePicker.View exposing (view)

import Components.DatePicker.Update
    exposing
        ( DateLimit(..)
        , Model
        , Msg(..)
        , TimePickerState(..)
        , ViewType(..)
        )
import Components.MonthPicker as MonthPicker
import Components.TimePicker.Update as TimePicker
import Components.TimePicker.View as TimePicker
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick)
import Utils.DateTime exposing (getMonthInt)
import Utils.Maybe as Maybe
import Utils.Time as Time


view : Model -> Html Msg
view ({ viewType, selectedDate } as model) =
    div [ class "date-time-picker" ]
        [ case viewType of
            Single ->
                singleCalendarView model

            Double ->
                doubleCalendarView model
        , case selectedDate of
            Just date ->
                singleClockView model

            Nothing ->
                text ""
        ]


singleCalendarView : Model -> Html Msg
singleCalendarView ({ dateLimit, primaryDate } as model) =
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
    div [ class "single-calendar-view no-select" ]
        [ MonthPicker.singleMonthPickerView2 pickerConfig
        , calendarView model
        , todayButtonHtml model
        ]


doubleCalendarView : Model -> Html Msg
doubleCalendarView ({ dateLimit, primaryDate } as model) =
    let
        nextDate =
            DateTime.incrementMonth primaryDate

        nextModel =
            { model | primaryDate = nextDate }

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
    in
    div [ class "double-calendar-view no-select" ]
        [ MonthPicker.doubleMonthPickerView2 pickerConfig
        , calendarView model
        , calendarView nextModel
        , todayButtonHtml model
        ]


singleClockView : Model -> Html Msg
singleClockView { timePicker, selectedDate } =
    case timePicker of
        TimePicker tp ->
            let
                displayDateHtml =
                    case selectedDate of
                        Just date ->
                            let
                                dateTimeStr =
                                    String.join " "
                                        [ Time.toHumanReadableDate date
                                        , TimePicker.toHumanReadableTime tp
                                        ]
                            in
                            span [ class "date" ] [ text dateTimeStr ]

                        Nothing ->
                            text ""

                pickerTypeString =
                    TimePicker.getPickerTypeString tp
            in
            div [ class ("single-clock-view " ++ pickerTypeString) ]
                [ div [ class "time-picker-container no-select" ]
                    [ span [ class "header" ] [ text "Pick-up Time" ]
                    , displayDateHtml
                    , Html.map TimePickerMsg (TimePicker.view tp)
                    ]
                ]

        _ ->
            text ""


calendarView : Model -> Html Msg
calendarView model =
    let
        monthDates =
            DateTime.getDatesInMonth model.primaryDate

        datesHtml =
            List.map (dateHtml model) monthDates

        precedingWeekdaysCount =
            case getFirstDayOfTheMonth model.primaryDate of
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
getFirstDayOfTheMonth : DateTime -> Maybe DateTime
getFirstDayOfTheMonth date =
    DateTime.fromRawParts
        { day = 1
        , month = DateTime.getMonth date
        , year = DateTime.getYear date
        }
        { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }


dateHtml : Model -> DateTime -> Html Msg
dateHtml ({ today, selectedDate } as model) date =
    let
        fullDateString =
            Time.toHumanReadableDate date

        ( isToday, isPastDate ) =
            ( areDatesEqual today date
            , DateTime.compareDates today date == GT
            )

        isSelected =
            Maybe.mapWithDefault (areDatesEqual date) False selectedDate

        isDisabledDate =
            checkIfDisabled model date

        dateClassList =
            [ ( "date", True )
            , ( "today", isToday )
            , ( "selected", isSelected )
            , ( "disabled", isDisabledDate )
            ]
    in
    if isDisabledDate then
        span
            [ classList dateClassList
            , title fullDateString
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]

    else
        span
            [ classList dateClassList
            , title fullDateString
            , onClick (SelectDate date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDay date)) ]
            ]


areDatesEqual : DateTime -> DateTime -> Bool
areDatesEqual lhs rhs =
    DateTime.compareDates lhs rhs == EQ


{-| Extract to another file as a common view fragment
-}
emptyDateHtml : Html msg
emptyDateHtml =
    span [ class "empty-date" ] []


{-| Checks if a Date on the DatePicker is a disabled one based on the specified date limitations.
-}
checkIfDisabled : Model -> DateTime -> Bool
checkIfDisabled { today, dateLimit } date =
    let
        isPastDate =
            DateTime.compareDates today date == GT
    in
    case dateLimit of
        NoLimit { disablePastDates } ->
            disablePastDates && isPastDate

        DateLimit { minDate, maxDate } ->
            let
                isPartOfTheConstraint =
                    (DateTime.compareDates minDate date == LT || areDatesEqual minDate date)
                        && (DateTime.compareDates maxDate date == GT || areDatesEqual maxDate date)
            in
            not isPartOfTheConstraint


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

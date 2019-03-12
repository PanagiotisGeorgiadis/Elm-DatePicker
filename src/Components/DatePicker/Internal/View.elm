module Components.DatePicker.Internal.View exposing (view)

import Components.Common
    exposing
        ( emptyDateHtml
        , getFirstDayOfTheMonth
        , totalCalendarCells
        , weekdaysHtml
        )
import Components.DatePicker.Internal.Update
    exposing
        ( Model(..)
        , Msg(..)
        , TimePickerState(..)
        , updatePrimaryDate
        )
import Components.DatePicker.Types
    exposing
        ( DateLimit(..)
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
import Utils.Time as Time


view : Model -> Html Msg
view ((Model { viewType, selectedDate }) as model) =
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
singleCalendarView ((Model { dateLimit, primaryDate }) as model) =
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
            , todayButtonHandler = MoveToToday
            }
    in
    div [ class "single-calendar-view no-select" ]
        [ MonthPicker.singleMonthPickerView pickerConfig
        , calendarView model
        ]


doubleCalendarView : Model -> Html Msg
doubleCalendarView ((Model { dateLimit, primaryDate }) as model) =
    let
        nextDate =
            DateTime.incrementMonth primaryDate

        nextModel =
            updatePrimaryDate nextDate model

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
            , todayButtonHandler = MoveToToday
            }
    in
    div [ class "double-calendar-view no-select" ]
        [ MonthPicker.doubleMonthPickerView pickerConfig
        , calendarView model
        , calendarView nextModel
        ]


singleClockView : Model -> Html Msg
singleClockView (Model model) =
    case model.timePicker of
        TimePicker { timePicker, pickerTitle } ->
            let
                displayDateHtml =
                    case model.selectedDate of
                        Just date ->
                            let
                                dateTimeStr =
                                    String.join " "
                                        [ Time.toHumanReadableDate date
                                        , TimePicker.toHumanReadableTime timePicker
                                        ]
                            in
                            span [ class "date" ] [ text dateTimeStr ]

                        Nothing ->
                            text ""

                pickerTypeString =
                    TimePicker.getPickerTypeString timePicker

                pickerTitleHtml =
                    if String.isEmpty pickerTitle then
                        text ""

                    else
                        span [ class "header" ] [ text pickerTitle ]
            in
            div [ class ("single-clock-view " ++ pickerTypeString) ]
                [ div [ class "time-picker-container no-select" ]
                    [ pickerTitleHtml
                    , displayDateHtml
                    , Html.map TimePickerMsg (TimePicker.view timePicker)
                    ]
                ]

        _ ->
            text ""


calendarView : Model -> Html Msg
calendarView ((Model { primaryDate }) as model) =
    let
        monthDates =
            DateTime.getDatesInMonth primaryDate

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
dateHtml ((Model { today, selectedDate }) as model) date =
    let
        fullDateString =
            Time.toHumanReadableDate date

        isEqualToDate date_ =
            DateTime.compareDates date date_ == EQ

        ( isToday, isPastDate ) =
            ( isEqualToDate today
            , DateTime.compareDates today date == GT
            )

        isSelected =
            case selectedDate of
                Just sd ->
                    isEqualToDate sd

                Nothing ->
                    False

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


{-| Checks if a Date on the DatePicker is a disabled one based on the specified date limitations.
-}
checkIfDisabled : Model -> DateTime -> Bool
checkIfDisabled (Model { today, dateLimit }) date =
    let
        isPastDate =
            DateTime.compareDates today date == GT

        isEqualToDate date_ =
            DateTime.compareDates date date_ == EQ
    in
    case dateLimit of
        NoLimit { disablePastDates } ->
            disablePastDates && isPastDate

        DateLimit { minDate, maxDate } ->
            let
                isPartOfTheConstraint =
                    (DateTime.compareDates minDate date == LT || isEqualToDate minDate)
                        && (DateTime.compareDates maxDate date == GT || isEqualToDate maxDate)
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

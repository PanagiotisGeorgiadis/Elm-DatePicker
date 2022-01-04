module DatePicker.Internal.View exposing (view)

import Common
    exposing
        ( emptyDateHtml
        , getFirstDayOfTheMonth
        , totalCalendarCells
        , weekdaysHtml
        )
import DatePicker.Internal.Update
    exposing
        ( Model(..)
        , Msg(..)
        , TimePickerState(..)
        , updatePrimaryDate
        )
import DatePicker.Types
    exposing
        ( DateLimit(..)
        , ViewType(..)
        )
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick)
import MonthPicker as MonthPicker
import TimePicker.Update as TimePicker
import TimePicker.View as TimePicker
import Utils.DateTime exposing (compareYearMonth)
import Utils.Time as Time


{-| The DatePicker view.
-}
view : Model -> Html Msg
view ((Model { viewType }) as model) =
    div [ class "date-time-picker" ]
        [ case viewType of
            Single ->
                singleCalendarView model

            Double ->
                doubleCalendarView model
        , singleClockView model
        ]


{-| A single calendar view.
-}
singleCalendarView : Model -> Html Msg
singleCalendarView ((Model { today, primaryDate, dateLimit, i18n }) as model) =
    let
        -- Decides the state of the previous & next month picker buttons.
        ( isPreviousButtonActive, isNextButtonActive, isTodayButtonActive ) =
            case dateLimit of
                DateLimit { minDate, maxDate } ->
                    ( compareYearMonth minDate primaryDate == LT
                    , compareYearMonth maxDate primaryDate == GT
                      -- If today is not in the DateRange we shouldn't render the Today button.
                    , compareYearMonth minDate today == LT && compareYearMonth maxDate today == GT
                    )

                Custom isDisabledDate ->
                    ( True
                    , True
                    , not <| isDisabledDate today today
                    )

                NoLimit ->
                    ( True
                    , True
                    , True
                    )

        pickerConfig =
            { date = primaryDate
            , nextButtonHandler = getNextButtonAction isNextButtonActive
            , previousButtonHandler = getPreviousButtonAction isPreviousButtonActive
            , todayButtonHandler = getTodayButtonAction isTodayButtonActive
            , i18n = i18n
            }
    in
    div [ class "single-calendar-view no-select" ]
        [ MonthPicker.singleMonthPickerView pickerConfig
        , calendarView model
        ]


{-| A double calendar view.
-}
doubleCalendarView : Model -> Html Msg
doubleCalendarView ((Model { today, primaryDate, dateLimit, i18n }) as model) =
    let
        nextDate =
            DateTime.incrementMonth primaryDate

        nextModel =
            updatePrimaryDate nextDate model

        -- Decides the state of the previous & next month picker buttons.
        ( isPreviousButtonActive, isNextButtonActive, isTodayButtonActive ) =
            case dateLimit of
                DateLimit { minDate, maxDate } ->
                    ( compareYearMonth minDate primaryDate == LT
                    , compareYearMonth maxDate nextDate == GT
                      -- If today is not in the DateRange we shouldn't render the Today button.
                    , compareYearMonth minDate today == LT && compareYearMonth maxDate today == GT
                    )

                Custom isDisabledDate ->
                    ( True
                    , True
                    , not <| isDisabledDate today today
                    )

                NoLimit ->
                    ( True
                    , True
                    , True
                    )

        pickerConfig =
            { date = primaryDate
            , nextButtonHandler = getNextButtonAction isNextButtonActive
            , previousButtonHandler = getPreviousButtonAction isPreviousButtonActive
            , todayButtonHandler = getTodayButtonAction isTodayButtonActive
            , i18n = i18n
            }
    in
    div [ class "double-calendar-view no-select" ]
        [ MonthPicker.doubleMonthPickerView pickerConfig
        , calendarView model
        , calendarView nextModel
        ]


{-| The view surrounding a single time picker. Also renders the picker title and the selected date.
-}
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
                                        [ Time.toHumanReadableDate model.i18n date
                                        , TimePicker.toHumanReadableTime timePicker
                                        ]
                            in
                            span [ class "date" ] [ text dateTimeStr ]

                        Nothing ->
                            span [ class "placeholder" ] []

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


{-| A Calendar view fragment. Contains all the calendar rendering logic.
-}
calendarView : Model -> Html Msg
calendarView ((Model { primaryDate, i18n, startingWeekday }) as model) =
    let
        monthDates =
            DateTime.getDatesInMonth primaryDate

        datesHtml =
            List.map (dateHtml model) monthDates

        precedingWeekdaysCount =
            case getFirstDayOfTheMonth primaryDate of
                Just firstDayOfTheMonth ->
                    Time.precedingWeekdays firstDayOfTheMonth startingWeekday

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
        [ weekdaysHtml startingWeekday i18n
        , div [ class "calendar_" ]
            (precedingDatesHtml ++ datesHtml ++ followingDatesHtml)
        ]


{-| Date view fragment. Contains all the logic for the `selected`, `disabled`, `today` dates.
-}
dateHtml : Model -> DateTime -> Html Msg
dateHtml ((Model { today, selectedDate, i18n }) as model) date =
    let
        fullDateString =
            Time.toHumanReadableDate i18n date

        isEqualToDate date_ =
            DateTime.compareDates date date_ == EQ

        isToday =
            isEqualToDate today

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


{-| Checks whether a given date is `disabled`.

  - The `disabled` dates are driven by the dateLimit value.
  - If there is no limit we allow for all the dates to be selected.
  - If there is some limit we disable all the dates outside of that range.

-}
checkIfDisabled : Model -> DateTime -> Bool
checkIfDisabled (Model { dateLimit, today }) date =
    case dateLimit of
        NoLimit ->
            False

        Custom isDisabledDate ->
            isDisabledDate date today

        DateLimit { minDate, maxDate } ->
            let
                isEqualToDate date_ =
                    DateTime.compareDates date date_ == EQ

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


getTodayButtonAction : Bool -> Maybe Msg
getTodayButtonAction isButtonActive =
    if isButtonActive then
        Just MoveToToday

    else
        Nothing

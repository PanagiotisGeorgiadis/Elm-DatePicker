module Components.DateRangePicker.Internal.View exposing (view)

import Clock
import Components.Common exposing (emptyDateHtml, getFirstDayOfTheMonth, totalCalendarCells, weekdaysHtml)
import Components.DateRangePicker.Internal.Update as Internal
    exposing
        ( DateRange(..)
        , DateRangeOffset(..)
        , Model(..)
        , Msg(..)
        , SelectionType(..)
        , TimePickerState(..)
        , ViewType(..)
        )
import Components.DateRangePicker.Types exposing (DateLimit(..))
import Components.MonthPicker as MonthPicker
import Components.TimePicker.Update as TimePicker
import Components.TimePicker.View as TimePicker
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Icons
import Utils.DateTime exposing (getMonthInt)
import Utils.Time as Time


{-| The DateRangePicker view.
-}
view : Model -> Html Msg
view ((Model { viewType, range }) as model) =
    div [ class "date-range-picker" ]
        (case viewType of
            SingleCalendar ->
                [ singleCalendarView model
                , case range of
                    BothSelected (Chosen _ _) ->
                        doubleClockView model

                    _ ->
                        text ""
                ]

            DoubleCalendar ->
                [ doubleCalendarView model
                ]

            DoubleTimePicker ->
                [ doubleClockView model
                ]
        )


{-| A single calendar view.
-}
singleCalendarView : Model -> Html Msg
singleCalendarView ((Model { primaryDate, dateLimit }) as model) =
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
    div
        [ class "single-calendar-view no-select"
        , onMouseLeave ResetVisualSelection
        ]
        [ MonthPicker.singleMonthPickerView pickerConfig
        , calendarView model
        ]


{-| A double calendar view.
-}
doubleCalendarView : Model -> Html Msg
doubleCalendarView ((Model { primaryDate, dateLimit, range, timePickers }) as model) =
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
            , todayButtonHandler = MoveToToday
            }

        nextModel =
            Internal.updatePrimaryDate nextDate model

        switchViewButton =
            case range of
                BothSelected (Chosen _ _) ->
                    div [ class "switch-view-button", onClick ShowClockView ] [ Icons.chevron Icons.Right (Icons.Size "20" "20") ]

                _ ->
                    div [ class "switch-view-button disabled" ] [ Icons.chevron Icons.Right (Icons.Size "20" "20") ]
    in
    div
        [ class "double-calendar-view no-select"
        , onMouseLeave ResetVisualSelection
        ]
        [ MonthPicker.doubleMonthPickerView pickerConfig
        , calendarView model
        , calendarView nextModel
        , case timePickers of
            NoTimePickers ->
                text ""

            _ ->
                switchViewButton
        ]


{-| The view surrounding two time pickers ( since we have a date range here ).
Also contains the picker titles and the mirrorTimes checkbox.
-}
doubleClockView : Model -> Html Msg
doubleClockView (Model { range, timePickers, viewType }) =
    case timePickers of
        TimePickers { startPicker, endPicker, pickerTitles, mirrorTimes } ->
            let
                displayDateHtml date timePicker =
                    case date of
                        Just d ->
                            let
                                dateTimeStr =
                                    String.join " "
                                        [ Time.toHumanReadableDate d
                                        , TimePicker.toHumanReadableTime timePicker
                                        ]
                            in
                            span [ class "date" ]
                                [ text dateTimeStr
                                ]

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
                        SingleCalendar ->
                            TimePicker.getPickerTypeString startPicker

                        _ ->
                            ""

                titleHtml str =
                    if String.isEmpty str then
                        text ""

                    else
                        span [ class "header" ] [ text str ]
            in
            div [ class ("double-clock-view " ++ pickerTypeString) ]
                [ div [ class "time-picker-container no-select" ]
                    [ titleHtml pickerTitles.start
                    , displayDateHtml rangeStart startPicker
                    , Html.map RangeStartPickerMsg (TimePicker.view startPicker)
                    , div [ class "checkbox", onClick ToggleTimeMirroring ]
                        [ Icons.checkbox (Icons.Size "16" "16") mirrorTimes
                        , span [ class "text" ] [ text ("Same as " ++ String.toLower pickerTitles.end) ]
                        ]
                    ]
                , div [ class "time-picker-container no-select" ]
                    [ titleHtml pickerTitles.end
                    , displayDateHtml rangeEnd endPicker
                    , Html.map RangeEndPickerMsg (TimePicker.view endPicker)
                    , div [ class "filler" ] []
                    ]
                , case viewType of
                    DoubleTimePicker ->
                        div [ class "switch-view-button", onClick ShowCalendarView ] [ Icons.chevron Icons.Left (Icons.Size "20" "20") ]

                    _ ->
                        text ""
                ]

        _ ->
            text ""


{-| A Calendar view fragment. Contains all the calendar rendering logic.
-}
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


{-| Date view fragment. Contains all the logic for the `date-range-start`,
`date-range-end`, `date-range`, `invalid`, `disabled`, `today` dates.
-}
dateHtml : Model -> DateTime -> Html Msg
dateHtml ((Model { today, range }) as model) date =
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
            isEqualToDate today

        isPartOfTheDateRange =
            let
                isDateBetween start end =
                    (isGreaterThanDate start && isLesserThanDate end)
                        || (isLesserThanDate start && isGreaterThanDate end)
            in
            case range of
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
                case range of
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
                case range of
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


{-| Checks whether a given date is `disabled`.

  - The `disabled` dates are driven by the dateLimit value.
  - If there is no limit we only check for past dates if `disablePastDates` === True.
  - If there is some limit we disable all the dates outside of that range.

-}
checkIfDisabled : Model -> DateTime -> Bool
checkIfDisabled (Model { today, dateLimit }) date =
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


{-| Checks whether a given date is `invalid`.

  - The `invalid` dates are defined in the dateRangeOffset.

-}
checkIfInvalid : Model -> DateTime -> Bool
checkIfInvalid (Model { dateRangeOffset }) date =
    case dateRangeOffset of
        Offset { invalidDates } ->
            List.any (\d -> DateTime.compareDates date d == EQ) invalidDates

        NoOffset ->
            False

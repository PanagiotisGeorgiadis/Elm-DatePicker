module Components.DateRangePicker2.View exposing (view)

import Components.DateRangePicker2.Update
    exposing
        ( DateLimit(..)
        , DateRangeOffset(..)
        , InternalViewType(..)
        , Model
        , Msg(..)
        , ViewType(..)
        )
import Components.MonthPicker as MonthPicker
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
    div [ class "date-time-picker horizontal-layout" ]
        [ case ( viewType, internalViewType ) of
            ( Single, CalendarView ) ->
                singleCalendarView model

            ( Single, ClockView ) ->
                text "Single Clock view"

            ( Double, CalendarView ) ->
                doubleCalendarView model

            ( Double, ClockView ) ->
                doubleClockView model
        ]


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

                -- _ ->
                --     -- FIXME: Fix that to work with the new DateLimit OR keep only the DateLimit ?
                --     -- ( isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit
                --     -- , isBetweenFutureLimit model.today model.primaryDate model.futureDatesLimit
                --     -- )
                --     ( True
                --     , True
                --     )
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
        [ class "single-calendar-view"
        , onMouseLeave ResetShadowDateRange
        ]
        [ MonthPicker.singleMonthPickerView2 pickerConfig
        , calendarView model
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

                -- _ ->
                --     -- FIXME: Fix that to work with the new DateLimit OR keep only the DateLimit ?
                --     -- ( isBetweenPastLimit model.today (DateTime.decrementMonth primaryDate) model.pastDatesLimit
                --     -- , isBetweenFutureLimit model.today nextDate model.futureDatesLimit
                --     -- )
                --     ( True
                --     , True
                --     )
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
        [ class "double-calendar-view"
        , onMouseLeave ResetShadowDateRange
        ]
        [ MonthPicker.doubleMonthPickerView2 pickerConfig
        , calendarView model
        , calendarView nextModel
        , case ( model.rangeStart, model.rangeEnd ) of
            ( Just start, Just end ) ->
                div [ class "switch-view-button", onClick ShowClockView ] [ Icons.chevron Icons.Right (Icons.Size "20" "20") ]

            _ ->
                div [ class "switch-view-button disabled" ] [ Icons.chevron Icons.Right (Icons.Size "20" "20") ]
        ]


doubleClockView : Model -> Html Msg
doubleClockView { rangeStart, rangeEnd, rangeStartTimePicker, rangeEndTimePicker, mirrorTimes } =
    let
        selectedDateHtml date =
            case date of
                Just d ->
                    span [ class "date" ] [ text (Time.toHumanReadableDateTime d) ]

                Nothing ->
                    text ""

        ( startTimePickerHtml, endTimePickerHtml ) =
            ( case rangeStartTimePicker of
                Just timePicker ->
                    Html.map RangeStartPickerMsg (TimePicker.view timePicker)

                Nothing ->
                    text ""
            , case rangeEndTimePicker of
                Just timePicker ->
                    Html.map RangeEndPickerMsg (TimePicker.view timePicker)

                Nothing ->
                    text ""
            )
    in
    div [ class "double-clock-view" ]
        [ div [ class "time-picker-container no-select" ]
            [ span [ class "header" ] [ text "Pick-up Time" ]
            , selectedDateHtml rangeStart
            , startTimePickerHtml
            , div [ class "checkbox", onClick ToggleTimeMirroring ]
                [ Icons.checkbox (Icons.Size "16" "16") mirrorTimes
                , span [ class "text" ] [ text "Same as drop-off time" ]
                ]
            ]
        , div [ class "time-picker-container no-select" ]
            [ span [ class "header" ] [ text "Drop-off Time" ]
            , selectedDateHtml rangeEnd
            , endTimePickerHtml
            , div [ class "filler" ] []
            ]
        , div [ class "switch-view-button", onClick ShowCalendarView ] [ Icons.chevron Icons.Left (Icons.Size "20" "20") ]
        ]


calendarView : Model -> Html Msg
calendarView ({ primaryDate } as model) =
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
dateHtml model date =
    let
        isDisabled =
            checkIfDisabled model date

        isInvalid =
            checkIfInvalid model date

        isToday =
            areDatesEqual model.today date

        ( visualRangeStart, visualRangeEnd ) =
            getVisualRangeEdges model

        isPartOfTheDateRange =
            case ( visualRangeStart, visualRangeEnd ) of
                ( Just start, Just end ) ->
                    (DateTime.compareDates start date == LT)
                        && (DateTime.compareDates end date == GT)

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
            -- ( visualRangeStart, visualRangeEnd ) =
            --     getVisualRangeEdges model
            --
            -- isPartOfTheDateRange =
            --     case ( visualRangeStart, visualRangeEnd ) of
            --         ( Just start, Just end ) ->
            --             (DateTime.compareDates start date == LT)
            --                 && (DateTime.compareDates end date == GT)
            --
            --         _ ->
            --             False
            ( isStartOfTheDateRange, isEndOfTheDateRange ) =
                ( Maybe.mapWithDefault (areDatesEqual date) False visualRangeStart
                , Maybe.mapWithDefault (areDatesEqual date) False visualRangeEnd
                )

            -- isDisabled =
            --     checkIfDisabled model date
            -- isToday =
            --     areDatesEqual model.today date
            dateClassList =
                [ ( "date", True )
                , ( "today", isToday )
                , ( "selected", isStartOfTheDateRange || isEndOfTheDateRange )
                , ( "date-range", isPartOfTheDateRange )

                -- The "not isEndOfTheDateRange && visualRangeEnd /= Nothing" clause is added in order to fix a css bug.
                , ( "date-range-start", isStartOfTheDateRange && not isEndOfTheDateRange && visualRangeEnd /= Nothing )

                -- The "not isStartOfTheDateRange" clause is added in order to fix a css bug.
                , ( "date-range-end", not isStartOfTheDateRange && isEndOfTheDateRange )

                -- , ( "invalid-selection", isInvalidSelection )
                -- , ( "disabled", isDisabled )
                ]
        in
        span
            [ classList dateClassList
            , title (Time.toHumanReadableDate date)
            , onClick (SelectDate date)
            , onMouseOver (DateHoverDetected date)
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


getVisualRangeEdges : Model -> ( Maybe DateTime, Maybe DateTime )
getVisualRangeEdges { rangeStart, rangeEnd, shadowRangeEnd } =
    case shadowRangeEnd of
        Just end ->
            sortMaybeDates rangeStart (Just end)

        Nothing ->
            sortMaybeDates rangeStart rangeEnd


checkIfDisabled : Model -> DateTime -> Bool
checkIfDisabled { today, dateLimit } date =
    let
        isPastDate =
            DateTime.compareDates today date == GT
    in
    case dateLimit of
        -- MonthLimit { disablePastDates } ->
        --     disablePastDates && isPastDate
        --
        -- YearLimit { disablePastDates } ->
        --     disablePastDates && isPastDate
        NoLimit { disablePastDates } ->
            disablePastDates && isPastDate

        DateLimit { minDate, maxDate } ->
            let
                isPartOfTheConstraint =
                    (DateTime.compareDates minDate date == LT || areDatesEqual minDate date)
                        && (DateTime.compareDates maxDate date == GT || areDatesEqual maxDate date)
            in
            not isPartOfTheConstraint


checkIfInvalid : Model -> DateTime -> Bool
checkIfInvalid { dateRangeOffset } date =
    case dateRangeOffset of
        Offset { invalidDates } ->
            List.any ((==) date) invalidDates

        NoOffset ->
            False


areDatesEqual : DateTime -> DateTime -> Bool
areDatesEqual lhs rhs =
    DateTime.compareDates lhs rhs == EQ


{-| Extract to another file as a common view fragment
-}
getFirstDayOfTheMonth : DateTime -> Maybe DateTime
getFirstDayOfTheMonth date =
    let
        ( month, year ) =
            ( DateTime.getMonth date
            , DateTime.getYear date
            )
    in
    DateTime.fromRawParts
        { day = 1, month = month, year = year }
        { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }


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


sortMaybeDates : Maybe DateTime -> Maybe DateTime -> ( Maybe DateTime, Maybe DateTime )
sortMaybeDates lhs rhs =
    case ( lhs, rhs ) of
        ( Just start, Just end ) ->
            case DateTime.compareDates start end of
                GT ->
                    ( Just end, Just start )

                _ ->
                    ( Just start, Just end )

        _ ->
            ( lhs, rhs )

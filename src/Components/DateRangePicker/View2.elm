module Components.DateRangePicker.View2 exposing (view)

import Components.DateRangePicker.Update
    exposing
        ( ConstrainedModel
        , Constraints
        , DateConstrains(..)
        , Model
        , Model2(..)
        , Msg(..)
        , ViewType(..)
        , getPrimaryDate
        , getViewType
        , updatePrimaryDate
        )
import Components.MonthPicker as MonthPicker
import DateTime.DateTime as DateTime exposing (DateTime)
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Models.Calendar exposing (isBetweenFutureLimit, isBetweenPastLimit)
import Utils.Html.Attributes as Attributes
import Utils.Maybe as Maybe
import Utils.Time as Time


view : Model2 -> Html Msg
view model =
    let
        monthPickerHtml =
            getMonthPickerHtml model

        viewType =
            getViewType model
    in
    case viewType of
        Single ->
            div
                [ class "single-calendar-view"
                , onMouseLeave ResetShadowDateRange
                ]
                [ monthPickerHtml

                -- , calendarView model
                , calendarView model
                ]

        Double ->
            let
                nextDate =
                    DateTime.getNextMonth (getPrimaryDate model)
            in
            div
                [ class "double-calendar-view"
                , onMouseLeave ResetShadowDateRange
                ]
                [ monthPickerHtml
                , calendarView model
                , calendarView (updatePrimaryDate nextDate model)
                ]


getMonthPickerHtml : Model2 -> Html Msg
getMonthPickerHtml m =
    case m of
        Constrained_ { minDate, maxDate } { primaryDate, viewType } ->
            let
                ( primaryDateMonthInt, nextDateMonthInt ) =
                    ( DateTime.getMonthInt primaryDate
                    , DateTime.getMonthInt (DateTime.getNextMonth primaryDate)
                    )

                getPickerConfig futureMonthInt =
                    { date = primaryDate
                    , nextButtonHandler = getNextMonthAction (DateTime.getMonthInt maxDate > futureMonthInt)
                    , previousButtonHandler = getPreviousMonthAction (DateTime.getMonthInt minDate < primaryDateMonthInt)
                    }
            in
            case viewType of
                Single ->
                    MonthPicker.singleMonthPickerView2 (getPickerConfig primaryDateMonthInt)

                Double ->
                    MonthPicker.doubleMonthPickerView2 (getPickerConfig nextDateMonthInt)

        Unconstrained_ { today, viewType, primaryDate, pastDatesLimit, futureDatesLimit } ->
            let
                getPickerConfig nextButtonDate =
                    { date = primaryDate
                    , nextButtonHandler = getNextMonthAction (isBetweenFutureLimit today nextButtonDate futureDatesLimit)
                    , previousButtonHandler = getPreviousMonthAction (isBetweenPastLimit today (DateTime.getPreviousMonth primaryDate) pastDatesLimit)
                    }
            in
            case viewType of
                Single ->
                    MonthPicker.singleMonthPickerView2 (getPickerConfig primaryDate)

                Double ->
                    MonthPicker.doubleMonthPickerView2 (getPickerConfig (DateTime.getNextMonth primaryDate))


calendarView : Model2 -> Html Msg
calendarView model =
    let
        primaryDate =
            getPrimaryDate model

        monthDates =
            DateTime.getDatesInMonth primaryDate

        datesHtml =
            -- List.map (dateHtml model) monthDates
            List.map (dateHtml123 model) monthDates

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


dateHtml123 : Model2 -> DateTime -> Html Msg
dateHtml123 model date =
    let
        ( visualRangeStart, visualRangeEnd ) =
            getVisualRangeEdges model

        isPartOfTheDateRange =
            case ( visualRangeStart, visualRangeEnd ) of
                ( Just start, Just end ) ->
                    (DateTime.compareDates start date == LT)
                        && (DateTime.compareDates end date == GT)

                _ ->
                    False

        ( isStartOfTheDateRange, isEndOfTheDateRange ) =
            ( Maybe.mapWithDefault (areDatesEqual date) False visualRangeStart
            , Maybe.mapWithDefault (areDatesEqual date) False visualRangeEnd
            )

        isDisabled =
            checkIfDisabled model date

        dateClassList =
            [ ( "date", True )
            , ( "today", isToday model date )
            , ( "selected", isStartOfTheDateRange || isEndOfTheDateRange )
            , ( "date-range", isPartOfTheDateRange )

            -- The "not isEndOfTheDateRange && visualRangeEnd /= Nothing" clause is added in order to fix a css bug.
            , ( "date-range-start", isStartOfTheDateRange && not isEndOfTheDateRange && visualRangeEnd /= Nothing )

            -- The "not isStartOfTheDateRange" clause is added in order to fix a css bug.
            , ( "date-range-end", not isStartOfTheDateRange && isEndOfTheDateRange )

            -- , ( "invalid-selection", isInvalidSelection )
            , ( "disabled", isDisabled )
            ]
    in
    if isDisabled then
        span
            [ classList dateClassList
            , title (Time.toHumanReadableDate date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDayInt date)) ]
            ]

    else
        span
            [ classList dateClassList
            , title (Time.toHumanReadableDate date)
            , onClick (SelectDate date)
            , onMouseOver (DateHoverDetected date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDayInt date)) ]
            ]


isToday : Model2 -> DateTime -> Bool
isToday model date =
    case model of
        Constrained_ _ { today } ->
            areDatesEqual today date

        Unconstrained_ { today } ->
            areDatesEqual today date


getVisualRangeEdges : Model2 -> ( Maybe DateTime, Maybe DateTime )
getVisualRangeEdges model =
    let
        getRangeEdges { rangeStart, rangeEnd, shadowRangeEnd } =
            case shadowRangeEnd of
                Just end ->
                    sortMaybeDates rangeStart (Just end)

                Nothing ->
                    sortMaybeDates rangeStart rangeEnd
    in
    case model of
        Constrained_ _ model_ ->
            getRangeEdges model_

        Unconstrained_ model_ ->
            getRangeEdges model_


checkIfDisabled : Model2 -> DateTime -> Bool
checkIfDisabled m date =
    case m of
        Constrained_ { minDate, maxDate } _ ->
            let
                isPartOfTheConstraint =
                    (DateTime.compareDates minDate date == LT || areDatesEqual minDate date)
                        && (DateTime.compareDates maxDate date == GT || areDatesEqual maxDate date)
            in
            not isPartOfTheConstraint

        Unconstrained_ { today, disablePastDates } ->
            let
                isPastDate =
                    DateTime.compareDates today date == GT
            in
            disablePastDates && isPastDate


getNextMonthAction : Bool -> Maybe Msg
getNextMonthAction isButtonActive =
    if isButtonActive then
        Just NextMonth

    else
        Nothing


getPreviousMonthAction : Bool -> Maybe Msg
getPreviousMonthAction isButtonActive =
    if isButtonActive then
        Just PreviousMonth

    else
        Nothing


areDatesEqual : DateTime -> DateTime -> Bool
areDatesEqual lhs rhs =
    DateTime.compareDates lhs rhs == EQ


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


{-| Extract to another file as a common view fragment
-}
getFirstDayOfTheMonth : DateTime -> Maybe DateTime
getFirstDayOfTheMonth date =
    DateTime.fromRawParts
        { rawYear = DateTime.getYearInt date
        , rawMonth = DateTime.getMonthInt date
        , rawDay = 1
        }
        { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }


{-| Extract to another file as a common view fragment
-}
weekdaysHtml : Html msg
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
emptyDateHtml : Html msg
emptyDateHtml =
    span [ class "empty-date" ] []



{- Extract to another file as a common view fragment -}


{-| 6 rows in total on the calendar
--- 7 columns on the calendar
--- 6 \* 7 = 42 is the total count of cells.
-}
totalCalendarCells : Int
totalCalendarCells =
    6 * 7

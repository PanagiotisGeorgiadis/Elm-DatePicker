module Components.DatePicker2.View exposing (view)

-- import DateTime.DateTime as DateTime exposing (DateTime)

import Components.DatePicker2.Update exposing (Model, Msg(..), ViewType(..))
import Components.MonthPicker as MonthPicker
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick)
import Models.Calendar exposing (isBetweenFutureLimit, isBetweenPastLimit)
import Utils.Html.Attributes as Attributes
import Utils.Maybe as Maybe
import Utils.Time as Time


view : Model -> Html Msg
view model =
    case model.viewType of
        Single ->
            let
                pickerConfig =
                    { date = model.primaryDate
                    , previousButtonHandler =
                        if isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit then
                            Just PreviousMonth

                        else
                            Nothing
                    , nextButtonHandler =
                        if isBetweenFutureLimit model.today model.primaryDate model.futureDatesLimit then
                            Just NextMonth

                        else
                            Nothing
                    }
            in
            div [ class "single-calendar-view" ]
                [ MonthPicker.singleMonthPickerView2 pickerConfig
                , calendarView model
                ]

        Double ->
            let
                nextDate =
                    DateTime.incrementMonth model.primaryDate

                nextModel =
                    { model | primaryDate = nextDate }

                pickerConfig =
                    { date = model.primaryDate
                    , previousButtonHandler =
                        if isBetweenPastLimit model.today (DateTime.decrementMonth model.primaryDate) model.pastDatesLimit then
                            Just PreviousMonth

                        else
                            Nothing
                    , nextButtonHandler =
                        if isBetweenFutureLimit model.today nextDate model.futureDatesLimit then
                            Just NextMonth

                        else
                            Nothing
                    }
            in
            div [ class "double-calendar-view" ]
                [ MonthPicker.doubleMonthPickerView2 pickerConfig
                , calendarView model
                , calendarView nextModel
                ]


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
dateHtml { today, selectedDate, disablePastDates } date =
    let
        fullDateString =
            Time.toHumanReadableDate date

        isToday =
            -- DateTime.compareDates today date == EQ
            areDatesEqual today date

        isPastDate =
            DateTime.compareDates today date == GT

        isSelected =
            -- Maybe.mapWithDefault ((==) date) False selectedDate
            Maybe.mapWithDefault (areDatesEqual date) False selectedDate

        -- isStartOfTheDateRange =
        --     Maybe.mapWithDefault ((==) date) False (List.head dateRange)
        --
        -- isEndOfTheDateRange =
        --     Maybe.mapWithDefault ((==) date) False (List.head <| List.reverse dateRange)
        -- isPartOfTheDateRange =
        --     if isStartOfTheDateRange || isEndOfTheDateRange then
        --         False
        --
        --     else
        --         List.any ((==) date) dateRange
        isDisabledDate =
            disablePastDates && isPastDate

        -- isInvalidSelection =
        --     case selectedDate of
        --         Just selectedDate_ ->
        --             let
        --                 dayDiff =
        --                     abs (DateTime.getDayDiff selectedDate_ date)
        --             in
        --             dayDiff < minDateRangeOffset
        --
        --         Nothing ->
        --             False
        dateClassList =
            [ ( "date", True )
            , ( "today", isToday )

            -- , ( "selected", isSelected || isStartOfTheDateRange || isEndOfTheDateRange )
            , ( "selected", isSelected )

            -- , ( "date-range", isPartOfTheDateRange )
            -- -- The "not isEndOfTheDateRange" clause is added in order to fix a css bug.
            -- , ( "date-range-start", isStartOfTheDateRange && not isEndOfTheDateRange )
            --
            -- -- The "not isStartOfTheDateRange" clause is added in order to fix a css bug.
            -- , ( "date-range-end", not isStartOfTheDateRange && isEndOfTheDateRange )
            -- , ( "invalid-selection", isInvalidSelection )
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



{- Extract to another file as a common view fragment -}


{-| 6 rows in total on the calendar
--- 7 columns on the calendar
--- 6 \* 7 = 42 is the total count of cells.
-}
totalCalendarCells : Int
totalCalendarCells =
    6 * 7

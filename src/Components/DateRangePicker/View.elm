module Components.DateRangePicker.View exposing (view)

import Components.DateRangePicker.Update exposing (Model, Msg(..), ViewType(..))
import Components.MonthPicker as MonthPicker
import DateTime.DateTime as DateTime exposing (DateTime)
import Html exposing (Attribute, Html, div, span, text)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Models.Calendar exposing (isBetweenFutureLimit, isBetweenPastLimit)
import Utils.Html.Attributes as Attributes
import Utils.Maybe as Maybe
import Utils.Time as Time


onMouseLeaveListener : Model -> Attribute Msg
onMouseLeaveListener model =
    if model.showOnHover then
        onMouseLeave ResetShadowDateRange

    else
        Attributes.none


view : Model -> Html Msg
view model =
    case model.viewType of
        Single ->
            let
                pickerConfig =
                    { date = model.primaryDate
                    , previousButtonHandler =
                        if isBetweenPastLimit model.today (DateTime.getPreviousMonth model.primaryDate) model.pastDatesLimit then
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
            div
                [ class "single-calendar-view"
                , onMouseLeaveListener model
                ]
                [ MonthPicker.singleMonthPickerView2 pickerConfig
                , calendarView model
                ]

        Double ->
            let
                nextDate =
                    DateTime.getNextMonth model.primaryDate

                nextModel =
                    { model | primaryDate = nextDate }

                pickerConfig =
                    { date = model.primaryDate
                    , previousButtonHandler =
                        if isBetweenPastLimit model.today (DateTime.getPreviousMonth model.primaryDate) model.pastDatesLimit then
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
            div
                [ class "double-calendar-view"
                , onMouseLeaveListener model
                ]
                [ MonthPicker.doubleMonthPickerView2 pickerConfig
                , calendarView model
                , calendarView nextModel
                ]


calendarView : Model -> Html Msg
calendarView model =
    let
        rangeEnd =
            case ( model.rangeEnd, model.shadowRangeEnd ) of
                ( Just end, _ ) ->
                    Just end

                ( _, Just end ) ->
                    Just end

                _ ->
                    model.rangeEnd

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


dateHtml : Model -> DateTime -> Html Msg
dateHtml model date =
    let
        rangeEnd =
            case model.shadowRangeEnd of
                Just end ->
                    Just end

                Nothing ->
                    model.rangeEnd

        ( visualRangeStart, visualRangeEnd ) =
            case ( model.rangeStart, rangeEnd ) of
                ( Just start, Just end ) ->
                    case DateTime.compareDates start end of
                        GT ->
                            ( Just end, Just start )

                        _ ->
                            ( Just start, Just end )

                _ ->
                    ( model.rangeStart, rangeEnd )

        fullDateString =
            Time.toHumanReadableDate date

        isToday =
            DateTime.compareDates model.today date == EQ

        isStartOfTheDateRange =
            Maybe.mapWithDefault ((==) date) False visualRangeStart

        isEndOfTheDateRange =
            Maybe.mapWithDefault ((==) date) False visualRangeEnd

        isPartOfTheDateRange =
            case ( visualRangeStart, visualRangeEnd ) of
                ( Just start, Just end ) ->
                    (DateTime.compareDates start date == LT) && (DateTime.compareDates end date == GT)

                _ ->
                    False

        isPastDate =
            DateTime.compareDates model.today date == GT

        isDisabledDate =
            model.disablePastDates && isPastDate

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
            , ( "selected", isStartOfTheDateRange || isEndOfTheDateRange )
            , ( "date-range", isPartOfTheDateRange )

            -- The "not isEndOfTheDateRange && visualRangeEnd /= Nothing" clause is added in order to fix a css bug.
            , ( "date-range-start", isStartOfTheDateRange && not isEndOfTheDateRange && visualRangeEnd /= Nothing )

            -- The "not isStartOfTheDateRange" clause is added in order to fix a css bug.
            , ( "date-range-end", not isStartOfTheDateRange && isEndOfTheDateRange )

            -- , ( "invalid-selection", isInvalidSelection )
            , ( "disabled", isDisabledDate )
            ]
    in
    if isDisabledDate then
        span
            [ classList dateClassList
            , title fullDateString
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDayInt date)) ]
            ]

    else
        span
            [ classList dateClassList
            , title fullDateString
            , if model.showOnHover then
                onMouseOver (DateHoverDetected date)

              else
                Attributes.none
            , onClick (SelectDate date)
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt (DateTime.getDayInt date)) ]
            ]


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

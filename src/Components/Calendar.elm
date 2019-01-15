module Components.Calendar exposing (view2)

import DateTime.Calendar as Calendar
import DateTime.DateTime as DateTime exposing (DateTime)
import Html exposing (..)
import Html.Attributes exposing (class, classList, title)
import Html.Events exposing (onClick, onMouseOver)
import Models.Calendar exposing (CalendarViewModel)
import Time exposing (Month(..), Weekday(..))
import Utils.Html.Attributes as Attributes
import Utils.Maybe as Maybe
import Utils.Time as Time


type alias DateViewModel msg =
    -- { today : Calendar.Date
    -- , date : Calendar.Date
    -- , dateRange : List Calendar.Date
    -- , selectedDate : Maybe Calendar.Date
    -- , dateSelectionHandler : Maybe (Calendar.Date -> msg)
    -- , onHoverListener : Maybe (Calendar.Date -> msg)
    -- }
    { today : DateTime
    , date : DateTime
    , dateRange : List DateTime
    , selectedDate : Maybe DateTime
    , dateSelectionHandler : Maybe (DateTime -> msg)
    , onHoverListener : Maybe (DateTime -> msg)
    , disablePastDates : Bool
    }



-- Not Used.
-- view : DateTime -> Html msg
-- view dateTime =
--     let
--         ( year, month ) =
--             ( DateTime.year dateTime
--             , DateTime.month dateTime
--             )
--
--         monthDays =
--             -- DateTime.daysInMonth year month
--             Calendar.dayToInt (Calendar.lastDayOf year month)
--
--         datesHtml =
--             List.map dateHtmlOld (List.range 1 monthDays)
--
--         firstWeekdayOfTheMonth =
--             -- RETHINK ABOUT THAT
--             -- Maybe.map (\day -> DateTime.setDay day dateTime) (Calendar.dayFromInt 1)
--             -- Write some tests for all this logic here and also the whole date package.
--             Maybe.map Calendar.weekdayFromDate (Calendar.fromRawYearMonthDay { rawYear = 2018, rawMonth = 11, rawDay = 1 })
--
--         -- firstWeekdayOfTheMonth =
--             -- DateTime.toPosix firstDayOfTheMonth
--
--         -- _ = Debug.log "January int" (Calendar.monthToInt Jan)
--         -- _ = Debug.log "February int" (Calendar.monthToInt Feb)
--         -- _ = Debug.log "March int" (Calendar.monthToInt Mar)
--         -- _ = Debug.log "April int" (Calendar.monthToInt Apr)
--         -- _ = Debug.log "May int" (Calendar.monthToInt May)
--         -- _ = Debug.log "June int" (Calendar.monthToInt Jun)
--         -- _ = Debug.log "July int" (Calendar.monthToInt Jul)
--         -- _ = Debug.log "August int" (Calendar.monthToInt Aug)
--         -- _ = Debug.log "September int" (Calendar.monthToInt Sep)
--         -- _ = Debug.log "October int" (Calendar.monthToInt Oct)
--         -- _ = Debug.log "November int" (Calendar.monthToInt Nov)
--         -- _ = Debug.log "December int" (Calendar.monthToInt Dec)
--
--         millis =
--             DateTime.dateTimeToMilliseconds True dateTime
--
--         precedingWeekdays_ =
--             Maybe.mapWithDefault Time.precedingWeekdays 0 firstWeekdayOfTheMonth
--
--         precedingDatesHtml_ =
--             -- Maybe.mapWithDefault precedingDatesHtml [] firstDayOfTheMonth
--             -- Maybe.mapWithDefault (\weekday -> List.range (precedingWeekdays weekday) emptyDateHtml) [] firstWeekdayOfTheMonth
--             List.repeat precedingWeekdays_ emptyDateHtml
--
--         followingDatesHtml =
--             List.repeat (totalCalendarCells - precedingWeekdays_ - monthDays) emptyDateHtml
--
--         -- 6 rows in total on the calendar
--         -- 7 columns on the calendar
--         -- 6 * 7 = 42 is the total count of cells.
--         -- 42 - precedingWeekdays_ - monthDays = followingDatesHtml
--
--         _ = Debug.log "firstWeekdayOfTheMonth" firstWeekdayOfTheMonth
--
--         -- _ = Debug.log "dateTime" dateTime
--         -- _ = Debug.log "month" month
--         -- _ = Debug.log "year" year
--         -- _ = Debug.log "Updated Day 1:" firstDayOfTheMonth
--     in
--     div [ class "calendar" ]
--         -- [ text "Calendar"
--         -- , br [] []
--         -- , text (monthToString month)
--         -- , text (String.fromInt monthDays)
--         -- , br [] []
--         -- , br [] []
--         [ weekdaysHtml
--         , div [ class "calendar_" ]
--             ( precedingDatesHtml_
--                 ++ datesHtml
--                 ++ followingDatesHtml
--             )
--         ]


type alias CalendarModel_ a =
    { a
        | today : DateTime
        , primaryDate : DateTime
        , disablePastDates : Bool

        -- , singleDate : Maybe Calendar.Date
        -- , dateRangeStart : Maybe Calendar.Date
        -- , dateRangeEnd : Maybe Calendar.Date
        -- , dateRange : List Calendar.Date
    }



-- view2 : Calendar.Date -> Html msg
-- view2 : CalendarModel -> CalendarViewModel msg -> Html msg


view2 : CalendarModel_ a -> CalendarViewModel msg -> Html msg
view2 { today, primaryDate, disablePastDates } { dateSelectionHandler, selectedDate, onHoverListener, rangeStart, rangeEnd } =
    let
        monthDates =
            DateTime.getDatesInMonth primaryDate

        dateRange =
            case ( rangeStart, rangeEnd ) of
                ( Just start, Just end ) ->
                    DateTime.getDateRange start end

                _ ->
                    []

        selectedDate_ =
            case ( selectedDate, rangeStart ) of
                ( Just date, _ ) ->
                    Just date

                ( _, Just date ) ->
                    Just date

                _ ->
                    Nothing

        dateViewModel date =
            { today = today
            , date = date
            , dateRange = dateRange
            , selectedDate = selectedDate_
            , dateSelectionHandler = dateSelectionHandler
            , onHoverListener = onHoverListener
            , disablePastDates = disablePastDates
            }

        datesHtml =
            List.map (dateHtml << dateViewModel) monthDates

        firstDayOfTheMonth =
            DateTime.fromRawParts
                { rawYear = DateTime.getYearInt primaryDate
                , rawMonth = DateTime.getMonthInt primaryDate
                , rawDay = 1
                }
                { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }

        firstWeekdayOfTheMonth =
            Maybe.map DateTime.getWeekday firstDayOfTheMonth

        precedingWeekdays_ =
            Maybe.mapWithDefault Time.precedingWeekdays 0 firstWeekdayOfTheMonth

        precedingDatesHtml =
            List.repeat precedingWeekdays_ emptyDateHtml

        followingDates =
            totalCalendarCells - precedingWeekdays_ - List.length monthDates

        followingDatesHtml =
            List.repeat followingDates emptyDateHtml
    in
    div [ class "calendar" ]
        [ weekdaysHtml
        , div [ class "calendar_" ]
            (precedingDatesHtml ++ datesHtml ++ followingDatesHtml)
        ]


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


dateHtml : DateViewModel msg -> Html msg
dateHtml { today, date, dateRange, dateSelectionHandler, selectedDate, onHoverListener, disablePastDates } =
    let
        date_ =
            -- Calendar.dayToInt (Calendar.getDay date)
            DateTime.getDayInt date

        fullDateString =
            Time.toHumanReadableDate date

        isToday =
            -- Maybe.mapWithDefault ((==) date) False today
            -- today == date
            DateTime.compareDates today date == EQ

        isPastDate =
            DateTime.compareDates today date == GT

        isSelected =
            Maybe.mapWithDefault ((==) date) False selectedDate

        isStartOfTheDateRange =
            Maybe.mapWithDefault ((==) date) False (List.head dateRange)

        isEndOfTheDateRange =
            Maybe.mapWithDefault ((==) date) False (List.head <| List.reverse dateRange)

        isPartOfTheDateRange =
            if isStartOfTheDateRange || isEndOfTheDateRange then
                False

            else
                List.any ((==) date) dateRange

        isDisabledDate =
            if disablePastDates then
                isPastDate

            else
                False

        dateClassList =
            [ ( "date", True )
            , ( "today", isToday )
            , ( "selected", isSelected || isStartOfTheDateRange || isEndOfTheDateRange )
            , ( "date-range", isPartOfTheDateRange )
            , ( "date-range-start", isStartOfTheDateRange )
            , ( "date-range-end", isEndOfTheDateRange )
            , ( "disabled", isDisabledDate )
            ]
    in
    if isDisabledDate then
        span [ classList dateClassList, title fullDateString ]
            [ span [ class "date-inner" ] [ text (String.fromInt date_) ]
            ]

    else
        span
            [ classList dateClassList
            , title fullDateString
            , case onHoverListener of
                Just listener ->
                    onMouseOver (listener date)

                Nothing ->
                    Attributes.none
            , case dateSelectionHandler of
                Just handler ->
                    onClick (handler date)

                Nothing ->
                    Attributes.none
            ]
            [ span [ class "date-inner" ] [ text (String.fromInt date_) ]
            ]


emptyDateHtml : Html msg
emptyDateHtml =
    span [ class "empty-date" ] []


{-| 6 rows in total on the calendar
--- 7 columns on the calendar
--- 6 \* 7 = 42 is the total count of cells.
-}
totalCalendarCells : Int
totalCalendarCells =
    6 * 7

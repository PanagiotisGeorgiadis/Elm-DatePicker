module Common exposing
    ( emptyDateHtml
    , getFirstDayOfTheMonth
    , getSortedWeekdays
    , totalCalendarCells
    , weekdaysHtml
    )

import DatePicker.I18n exposing (I18n, TextMode(..))
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Time exposing (Weekday(..))



-- Common View Fragments


getSortedWeekdays : Weekday -> List Weekday
getSortedWeekdays startingWeekday =
    case startingWeekday of
        Sun ->
            [ Sun, Mon, Tue, Wed, Thu, Fri, Sat ]

        Mon ->
            [ Mon, Tue, Wed, Thu, Fri, Sat, Sun ]

        Tue ->
            [ Tue, Wed, Thu, Fri, Sat, Sun, Mon ]

        Wed ->
            [ Wed, Thu, Fri, Sat, Sun, Mon, Tue ]

        Thu ->
            [ Thu, Fri, Sat, Sun, Mon, Tue, Wed ]

        Fri ->
            [ Fri, Sat, Sun, Mon, Tue, Wed, Thu ]

        Sat ->
            [ Sat, Sun, Mon, Tue, Wed, Thu, Fri ]


weekdaysHtml : Weekday -> I18n -> Html msg
weekdaysHtml weekday i18n =
    div [ class "weekdays" ] <|
        List.map
            (\w -> span [] [ text (i18n.weekdayToString Condensed w) ])
            (getSortedWeekdays weekday)


emptyDateHtml : Html msg
emptyDateHtml =
    span [ class "empty-date" ] []



-- Common Utility Functions


{-| 6 rows in total on the calendar
7 columns on the calendar
6 \* 7 = 42 is the total count of cells.
-}
totalCalendarCells : Int
totalCalendarCells =
    6 * 7


{-| Returns the first day of the month using midnight time.
-}
getFirstDayOfTheMonth : DateTime -> Maybe DateTime
getFirstDayOfTheMonth =
    DateTime.setDay 1

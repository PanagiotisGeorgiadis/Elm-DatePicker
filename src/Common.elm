module Common exposing
    ( emptyDateHtml
    , getFirstDayOfTheMonth
    , totalCalendarCells
    , weekdaysHtml
    )

import Clock
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)



-- Common View Fragments


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

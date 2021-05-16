module Common exposing
    ( emptyDateHtml
    , getFirstDayOfTheMonth
    , totalCalendarCells
    , weekdaysHtml
    )

import DatePicker.I18n exposing (I18n, TextMode(..))
import DateTime exposing (DateTime)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Time exposing (Weekday(..))



-- Common View Fragments


weekdaysHtml : I18n -> Html msg
weekdaysHtml i18n =
    div [ class "weekdays" ]
        [ span [] [ text (i18n.weekdayToString Condensed Sun) ]
        , span [] [ text (i18n.weekdayToString Condensed Mon) ]
        , span [] [ text (i18n.weekdayToString Condensed Tue) ]
        , span [] [ text (i18n.weekdayToString Condensed Wed) ]
        , span [] [ text (i18n.weekdayToString Condensed Thu) ]
        , span [] [ text (i18n.weekdayToString Condensed Fri) ]
        , span [] [ text (i18n.weekdayToString Condensed Sat) ]
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

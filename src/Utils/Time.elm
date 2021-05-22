module Utils.Time exposing
    ( monthToString
    , precedingWeekdays
    , toHumanReadableDate
    )

import Common
import DatePicker.I18n exposing (I18n, TextMode(..))
import DateTime exposing (DateTime)
import Time exposing (Month(..), Weekday(..))


{-| Returns a formatted date from a given DateTime.

    -- dateTime = 27 Sep 2019 14:57:45.160
    toHumanReadableDate dateTime -- "Fri 27 Sep 2019" : String

-}
toHumanReadableDate : I18n -> DateTime -> String
toHumanReadableDate i18n dateTime =
    String.join " "
        [ i18n.weekdayToString Condensed (DateTime.getWeekday dateTime)
        , String.fromInt (DateTime.getDay dateTime)
        , i18n.monthToString Condensed (DateTime.getMonth dateTime)
        , String.fromInt (DateTime.getYear dateTime)
        ]


{-| Transforms a Weekday to a String.
-}
weekdayToString : Weekday -> String
weekdayToString weekday =
    case weekday of
        Mon ->
            "Monday"

        Tue ->
            "Tuesday"

        Wed ->
            "Wednesday"

        Thu ->
            "Thursday"

        Fri ->
            "Friday"

        Sat ->
            "Saturday"

        Sun ->
            "Sunday"


{-| Transforms a Weekday to a condensed String.

    weekdayToStringCondensed Fri : "Fri" String

-}
weekdayToStringCondensed : Weekday -> String
weekdayToStringCondensed =
    String.left 3 << weekdayToString


{-| Transforms a Month to a String.
-}
monthToString : Month -> String
monthToString month =
    case month of
        Jan ->
            "January"

        Feb ->
            "February"

        Mar ->
            "March"

        Apr ->
            "April"

        May ->
            "May"

        Jun ->
            "June"

        Jul ->
            "July"

        Aug ->
            "August"

        Sep ->
            "September"

        Oct ->
            "October"

        Nov ->
            "November"

        Dec ->
            "December"


{-| Transforms a Month to a condensed String.

    monthToStringCondensed Aug : "Aug" String

-}
monthToStringCondensed : Month -> String
monthToStringCondensed =
    String.left 3 << monthToString


type PrecedingWeekdaysMatch
    = Searching Int
    | Matched Int


{-| Gets the precedingWeekdays based on the `startingWeekday` of the Calendar config
and the `firstWeekday` of the current month.
-}
precedingWeekdays : DateTime -> Weekday -> Int
precedingWeekdays firstDayOfTheMonth startingWeekday =
    let
        firstWeekdayOfTheMonth =
            DateTime.getWeekday firstDayOfTheMonth

        precedingWeekdaysMatch =
            List.foldl
                (\weekday res ->
                    case res of
                        Matched c ->
                            Matched c

                        Searching c ->
                            if weekday == firstWeekdayOfTheMonth then
                                Matched c

                            else
                                Searching (c + 1)
                )
                (Searching 0)
                (Common.getSortedWeekdays startingWeekday)
    in
    case precedingWeekdaysMatch of
        Searching _ ->
            0

        Matched c ->
            c

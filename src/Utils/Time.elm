module Utils.Time exposing
    ( millisToString
    , monthToString
    , precedingWeekdays
    , timeToString
    , toHumanReadableDate
    )

import DateTime exposing (DateTime)
import Time exposing (Month(..), Posix, Weekday(..), Zone)


{-| Returns a formatted date from a given DateTime.

    -- dateTime = 27 Sep 2019 14:57:45.160
    toHumanReadableDate dateTime -- "Fri 27 Sep 2019" : String

-}
toHumanReadableDate : DateTime -> String
toHumanReadableDate dateTime =
    String.join " "
        [ weekdayToStringCondensed (DateTime.getWeekday dateTime)
        , String.fromInt (DateTime.getDay dateTime)
        , monthToStringCondensed (DateTime.getMonth dateTime)
        , String.fromInt (DateTime.getYear dateTime)
        ]


{-| Formats `Hours`, `Minutes`, `Seconds` to a representation String.

    timeToString 0 -- "00" : String

    timeToString 30 -- "30" : String

-}
timeToString : Int -> String
timeToString time =
    if time < 10 then
        "0" ++ String.fromInt time

    else
        String.fromInt time


{-| Formats `Milliseconds` to a representation String.

    millisToString 1 -- "001" : String

    millisToString 10 -- "010" : String

    millisToString 100 -- "100" : String

-}
millisToString : Int -> String
millisToString millis =
    if millis < 10 then
        "00" ++ String.fromInt millis

    else if millis < 100 then
        "0" ++ String.fromInt millis

    else
        String.fromInt millis


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


{-| Gets the precedingWeekdays based on the assumption that the week starts
on Sunday. May need to rething a better approach for that.
-}
precedingWeekdays : Weekday -> Int
precedingWeekdays weekday =
    case weekday of
        Sun ->
            0

        Mon ->
            1

        Tue ->
            2

        Wed ->
            3

        Thu ->
            4

        Fri ->
            5

        Sat ->
            6

module Utils.Time exposing
    ( monthToString
    , monthToStringCondensed
    , precedingWeekdays
    , timeToString
    , toHumanReadableDate
    , toHumanReadableDateTime
    , weekdayToString
    , weekdayToStringCondensed
    )

import DateTime exposing (DateTime)
import Time exposing (Month(..), Posix, Weekday(..), Zone)


toHumanReadableDateTime : DateTime -> String
toHumanReadableDateTime dateTime =
    let
        humanReadableTime =
            String.join ":"
                [ timeToString (DateTime.getHours dateTime)
                , timeToString (DateTime.getMinutes dateTime)
                ]
    in
    String.join " "
        [ toHumanReadableDate dateTime
        , humanReadableTime
        ]


toHumanReadableDate : DateTime -> String
toHumanReadableDate dateTime =
    String.join " "
        [ weekdayToStringCondensed (DateTime.getWeekday dateTime)
        , String.fromInt (DateTime.getDay dateTime)
        , monthToStringCondensed (DateTime.getMonth dateTime)
        , String.fromInt (DateTime.getYear dateTime)
        ]


timeToString : Int -> String
timeToString time =
    if time < 10 then
        "0" ++ String.fromInt time

    else
        String.fromInt time


millisToString : Int -> String
millisToString millis =
    if millis < 10 then
        "00" ++ String.fromInt millis

    else if millis < 100 then
        "0" ++ String.fromInt millis

    else
        String.fromInt millis


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


weekdayToStringCondensed : Weekday -> String
weekdayToStringCondensed =
    String.left 3 << weekdayToString


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


monthToStringCondensed : Month -> String
monthToStringCondensed =
    String.left 3 << monthToString


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

module Utils.Time exposing
    ( monthToString
    , monthToStringCondensed
    , precedingWeekdays
    , timeToString
    , toHumanReadableDate
    , toHumanReadableTime
    , weekdayToString
    , weekdayToStringCondensed
    , zeroTime
    )

-- import DateTime.Calendar as Calendar

import DateTime.DateTime as DateTime exposing (DateTime)
import Time exposing (Month(..), Posix, Weekday(..), Zone)


zeroTime : Posix
zeroTime =
    Time.millisToPosix 0


toHumanReadableTime : Zone -> Posix -> String
toHumanReadableTime zone time =
    let
        ( weekday, month ) =
            ( Time.toWeekday zone time
            , Time.toMonth zone time
            )

        ( day, year, experiment ) =
            ( Time.toDay zone time
            , Time.toYear zone time
            , 0
            )

        humanReadableTime =
            String.join ":"
                [ timeToString (Time.toHour zone time)
                , timeToString (Time.toMinute zone time)
                , timeToString (Time.toSecond zone time)
                ]
    in
    String.join " "
        [ weekdayToStringCondensed weekday
        , monthToStringCondensed month
        , String.fromInt day
        , String.fromInt year
        , humanReadableTime
        ]


timeToString : Int -> String
timeToString time =
    if time == 0 then
        "00"

    else if time < 10 then
        "0" ++ String.fromInt time

    else
        String.fromInt time


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



-- monthToInt : Month -> Int
-- monthToInt month =
--     case month of
--         Jan ->
--             1
--         Feb ->
--             2
--         Mar ->
--             3
--         Apr ->
--             4
--         May ->
--             5
--         Jun ->
--             6
--         Jul ->
--             7
--         Aug ->
--             8
--         Sep ->
--             9
--         Oct ->
--             10
--         Nov ->
--             11
--         Dec ->
--             12
--
--
-- monthFromInt : Int -> Maybe Month
-- monthFromInt monthInt =
--     case monthInt of
--         1 -> Just Jan
--         2 -> Just Feb
--         3 -> Just Mar
--         4 -> Just Apr
--         5 -> Just May
--         6 -> Just Jun
--         7 -> Just Jul
--         8 -> Just Aug
--         9 -> Just Sep
--         10 -> Just Oct
--         11 -> Just Nov
--         12 -> Just Dec
--         _ -> Nothing
-- getPreviousMonth : Month -> Month
-- getPreviousMonth month =
--     case month of
--         Jan -> Dec
--         Feb -> Jan
--         Mar -> Feb
--         Apr -> Mar
--         May -> Apr
--         Jun -> May
--         Jul -> Jun
--         Aug -> Jul
--         Sep -> Aug
--         Oct -> Sep
--         Nov -> Oct
--         Dec -> Nov
--
--
-- getNextMonth : Month -> Month
-- getNextMonth month =
--     case month of
--         Jan -> Feb
--         Feb -> Mar
--         Mar -> Apr
--         Apr -> May
--         May -> Jun
--         Jun -> Jul
--         Jul -> Aug
--         Aug -> Sep
--         Sep -> Oct
--         Oct -> Nov
--         Nov -> Dec
--         Dec -> Jan


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



{- We'll see -}


toHumanReadableDate : DateTime -> String
toHumanReadableDate date =
    String.join " "
        [ weekdayToString (DateTime.getWeekday date)
        , String.fromInt (DateTime.getDayInt date)
        , monthToStringCondensed (DateTime.getMonth date)
        , String.fromInt (DateTime.getYearInt date)
        ]

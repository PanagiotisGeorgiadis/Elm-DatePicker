module Utils.DateTime exposing
    ( decrementDays
    , getMonthInt
    , incrementDays
    )

import Calendar
import DateTime exposing (DateTime)


getMonthInt : DateTime -> Int
getMonthInt =
    Calendar.monthToInt << DateTime.getMonth


incrementDays : Int -> DateTime -> DateTime
incrementDays days date =
    if days > 0 then
        incrementDays (days - 1) (DateTime.incrementDay date)

    else
        date


decrementDays : Int -> DateTime -> DateTime
decrementDays days date =
    if days > 0 then
        decrementDays (days - 1) (DateTime.decrementDay date)

    else
        date

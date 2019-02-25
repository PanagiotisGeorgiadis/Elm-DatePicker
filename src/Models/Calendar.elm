module Models.Calendar exposing
    ( decrementDays
    , incrementDays
    )

import DateTime exposing (DateTime)
import Utils.DateTime exposing (getMonthInt)


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

module Utils.DateTime exposing
    ( compareYearMonth
    , decrementDays
    , incrementDays
    )

import Calendar
import DateTime exposing (DateTime)


{-| Increments the Day part of a DateTime by `n` number of times.
-}
incrementDays : Int -> DateTime -> DateTime
incrementDays days date =
    if days > 0 then
        incrementDays (days - 1) (DateTime.incrementDay date)

    else
        date


{-| Decrements the Day part of a DateTime by `n` number of times.
-}
decrementDays : Int -> DateTime -> DateTime
decrementDays days date =
    if days > 0 then
        decrementDays (days - 1) (DateTime.decrementDay date)

    else
        date


{-| Returns the month of a DateTime as an integer.
-}
getMonthInt : DateTime -> Int
getMonthInt =
    Calendar.monthToInt << DateTime.getMonth


{-| Compares two DateTimes based on their `Year` and `Month` parts.
-}
compareYearMonth : DateTime -> DateTime -> Order
compareYearMonth lhs rhs =
    let
        yearsComparison =
            Basics.compare (DateTime.getYear lhs) (DateTime.getYear rhs)
    in
    case yearsComparison of
        EQ ->
            Basics.compare (getMonthInt lhs) (getMonthInt rhs)

        _ ->
            yearsComparison

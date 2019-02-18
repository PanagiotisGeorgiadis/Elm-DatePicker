module Utils.DateTime exposing (getMonthInt)

import Calendar
import DateTime exposing (DateTime)


getMonthInt : DateTime -> Int
getMonthInt =
    Calendar.monthToInt << DateTime.getMonth

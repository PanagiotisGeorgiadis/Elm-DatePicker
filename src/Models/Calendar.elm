module Models.Calendar exposing
    ( CalendarViewModel
    , DateLimit(..)
    , decrementDays
    , incrementDays
    , isBetweenFutureLimit
    , isBetweenPastLimit
    )

import DateTime.DateTime as DateTime exposing (DateTime)



-- Implement it later on.
-- type alias SingleCalendarModelViewModel =
--     { dateSelectionHandler : Maybe (Calendar.Date -> msg)
--     , selectedDate : Maybe Calendar.Date
--     }
-- type alias CalendarModel =
--     { today: Calendar.Date
--     , primaryDate : Calendar.Date
--     -- , dateSelectionHandler : Maybe (Calendar.Date -> msg)
--     , singleDate : Maybe Calendar.Date
--     , dateRangeStart : Maybe Calendar.Date
--     , dateRangeEnd : Maybe Calendar.Date
--     , dateRange : List Calendar.Date
--     }
-- Maybe I'll change that to just accept a date
-- and make today + primaryDate the same. Then you can
-- Change only the primaryDate.
-- Also maybe rename the primaryDate to previewDate or sth like that.
-- initialCalendarModel : Calendar.Date -> CalendarModel
-- initialCalendarModel today =
--     { today = today
--     , primaryDate = today
--     , singleDate = Nothing
--     , dateRangeStart = Nothing
--     , dateRangeEnd = Nothing
--     , dateRange = []
--     -- , dateSelectionHandler = Nothing
--     }
{--Maybe turn this to a union type, something like:
    type CalendarViewModel
        = SingleCalendarViewModel SingleCalendarConfig
        | DoubleCalendarViewModel DoubleCalendarConfig

    So that one of them can have a date range and then
    other can have a selectedDate.

    Also you can think about having one View model for
    date ranges and one for single day selection.
    We just need to think about all that more thoroughly.
--}


type alias CalendarViewModel msg =
    { dateSelectionHandler : Maybe (DateTime -> msg)
    , selectedDate : Maybe DateTime
    , onHoverListener : Maybe (DateTime -> msg)
    , rangeStart : Maybe DateTime
    , rangeEnd : Maybe DateTime
    }


type DateLimit
    = NoLimit
    | MonthLimit Int
    | YearLimit Int


getYearDiff : DateTime -> DateTime -> Int
getYearDiff lhs rhs =
    DateTime.getYearInt rhs - DateTime.getYearInt lhs


getMonthDiff : DateTime -> DateTime -> Int
getMonthDiff lhs rhs =
    (getYearDiff lhs rhs * 12) + (DateTime.getMonthInt rhs - DateTime.getMonthInt lhs)


isBetweenFutureLimit : DateTime -> DateTime -> DateLimit -> Bool
isBetweenFutureLimit lhs rhs dateLimit =
    -- let
    --     yearDiff =
    --         DateTime.getYearInt rhs - DateTime.getYearInt lhs
    --
    --     monthDiff =
    --         (yearDiff * 12) + (DateTime.getMonthInt rhs - DateTime.getMonthInt lhs)
    -- in
    case dateLimit of
        NoLimit ->
            True

        MonthLimit limit ->
            getMonthDiff lhs rhs < limit

        YearLimit limit ->
            getYearDiff lhs rhs < limit


isBetweenPastLimit : DateTime -> DateTime -> DateLimit -> Bool
isBetweenPastLimit lhs rhs dateLimit =
    -- let
    --     yearDiff =
    --         DateTime.getYearInt rhs - DateTime.getYearInt lhs
    --
    --     monthDiff =
    --         (yearDiff * 12) + (DateTime.getMonthInt rhs - DateTime.getMonthInt lhs)
    -- in
    case dateLimit of
        NoLimit ->
            True

        MonthLimit limit ->
            getMonthDiff lhs rhs >= negate limit

        YearLimit limit ->
            getYearDiff lhs rhs >= negate limit


incrementDays : Int -> DateTime -> DateTime
incrementDays days date =
    if days > 0 then
        incrementDays (days - 1) (DateTime.getNextDay date)

    else
        date


decrementDays : Int -> DateTime -> DateTime
decrementDays days date =
    if days > 0 then
        decrementDays (days - 1) (DateTime.getPreviousDay date)

    else
        date

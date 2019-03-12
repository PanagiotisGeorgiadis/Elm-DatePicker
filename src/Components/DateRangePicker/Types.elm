module Components.DateRangePicker.Types exposing
    ( CalendarConfig
    , DateLimit(..)
    , TimePickerConfig
    )

{-| This common file contains common types that are being used by both
the internal and external DateRangePicker module.
-}

import Clock
import Components.TimePicker.Types as TimePicker
import DateTime exposing (DateTime)


{-| Used in order to configure the `Calendar` part of the `DateRangePicker`.
-}
type alias CalendarConfig =
    { today : DateTime
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , dateRangeOffset : Maybe { minDateRangeLength : Int }
    }


{-| Used in order to configure the `TimePicker` part of the `DateRangePicker`.
-}
type alias TimePickerConfig =
    { pickerType : TimePicker.PickerType
    , defaultTime : Clock.Time
    , pickerTitles : { start : String, end : String }
    , mirrorTimes : Bool
    }


{-| The `optional` Calendar date restrictions. You can impose all the types of
different restrictions by using this simple type.

NoLimit { disablePastDates = False } -- An unlimited Calendar.

NoLimit { disablePastDates = True } -- Allows only `future date selection`.

DateLimit { minDate = 1 Jan 2019, maxDate = 31 Dec 2019 }
-- A Custom imposed restriction for the year 2019 inclusive of the
minDate and maxDate.

-}
type DateLimit
    = DateLimit { minDate : DateTime, maxDate : DateTime }
    | NoLimit { disablePastDates : Bool }

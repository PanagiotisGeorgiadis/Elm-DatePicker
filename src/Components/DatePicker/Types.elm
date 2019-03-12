module Components.DatePicker.Types exposing
    ( CalendarConfig
    , DateLimit(..)
    , TimePickerConfig
    , ViewType(..)
    )

import Clock
import Components.TimePicker.Types as TimePicker
import DateTime exposing (DateTime)



-- {-| This module contains the `Public types` that can be used by the consumer.
-- -}


{-| The Calendar ViewType.

Single DatePicker with no TimePickers:

Single DatePicker with TimePickers:

Double DatePicker with no TimePickers:

Double DatePicker with TimePickers:

-}
type ViewType
    = Single
    | Double


{-| Used in order to configure the `Calendar` part of the `DateRangePicker`.
-}
type alias CalendarConfig =
    { today : DateTime
    , primaryDate : DateTime
    , dateLimit : DateLimit
    }


{-| Used in order to configure the `TimePicker` part of the `DateRangePicker`.
-}
type alias TimePickerConfig =
    { pickerType : TimePicker.PickerType
    , defaultTime : Clock.Time
    , pickerTitle : String
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

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

[Single date picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Single-Date-Picker.png "Single date picker")

[Single date-time picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Single-DateTime-Picker.png "Single date-time picker")

[Double date picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Double-Date-Picker.png "Double date picker.")

[Double date-time picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Double-DateTime-Picker.png "Double date-time picker")

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
    -- A Custom imposed restriction for the calendar year 2019.
    -- Note: The date limit imposed is including the minDate and maxDate as valid dates.

-}
type DateLimit
    = DateLimit { minDate : DateTime, maxDate : DateTime }
    | NoLimit { disablePastDates : Bool }

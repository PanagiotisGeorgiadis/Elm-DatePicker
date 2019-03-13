module Components.DateRangePicker.Types exposing
    ( CalendarConfig
    , DateLimit(..)
    , TimePickerConfig
    , ViewType(..)
    )

{-| This common file contains common types that are being used by both
the internal and external DateRangePicker module.
-}

import Clock
import Components.TimePicker.Types as TimePicker
import DateTime exposing (DateTime)


{-| The Calendar ViewType.

[Single date range picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Single-Date-RangePicker.png "Single date range picker")

[Single date-time range picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Single-DateTime-RangePicker.png "Single date-time range picker")

[Double date range picker](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Double-Date-RangePicker.png "Double date-time range picker")

[Double date-time range picker (Calendar)](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Double-DateTime-RangePicker-1.png "Double date range picker (Calendar).")
[Double date-time range picker (Time Pickers)](https://raw.githubusercontent.com/PanagiotisGeorgiadis/Elm-DatePicker/master/assets/Double-DateTime-RangePicker-2.png "Double date range picker (Time Pickers).")

-}
type ViewType
    = Single
    | Double


{-| Used in order to configure the `Calendar` part of the `DateRangePicker`.
-}
type alias CalendarConfig =
    { today : DateTime
    , primaryDate : Maybe DateTime
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

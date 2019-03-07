module Components.DateRangePicker.Internal.Update exposing
    ( DateRange(..)
    , DateRangeOffset(..)
    , InternalViewType(..)
    , SelectionType(..)
    , TimePickerConfig
    , TimePickerState(..)
    )

import Clock
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)


{-| Internal
-}
type DateRangeOffset
    = Offset { invalidDates : List DateTime, minDateRangeLength : Int }
    | NoOffset


{-| Internal
-}
type DateRange
    = NoneSelected
    | StartDateSelected DateTime
    | BothSelected SelectionType


{-| Internal
-}
type SelectionType
    = Visually DateTime DateTime
    | Chosen DateTime DateTime


{-| Internal
-}
type InternalViewType
    = CalendarView
    | ClockView


{-| Internal
-}
type TimePickerState
    = NoTimePickers
    | NotInitialised TimePickerConfig
    | TimePickers { startPicker : TimePicker.Model, endPicker : TimePicker.Model, pickerTitles : { start : String, end : String }, mirrorTimes : Bool }


{-| Expose
-}
type alias TimePickerConfig =
    { pickerType : TimePicker.PickerType
    , defaultTime : Clock.Time
    , pickerTitles : { start : String, end : String }
    , mirrorTimes : Bool
    }

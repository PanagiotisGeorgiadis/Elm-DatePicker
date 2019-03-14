module TimePicker.Types exposing (PickerType(..))

{-| This module contains the `Public types` that can be used in order to create a TimePickerConfig
for either the `DatePicker` or the `DateRangePicker` modules.

@docs PickerType

-}


{-| Describes different picker types.
-}
type PickerType
    = HH { hoursStep : Int }
    | HH_MM { hoursStep : Int, minutesStep : Int }
    | HH_MM_SS { hoursStep : Int, minutesStep : Int, secondsStep : Int }
    | HH_MM_SS_MMMM { hoursStep : Int, minutesStep : Int, secondsStep : Int, millisecondsStep : Int }

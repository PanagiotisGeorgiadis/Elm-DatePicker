module TimePicker.Types exposing (PickerType(..))

{-| This module contains the `Public types` that are being used by the
_**parent application**_ in order to create a `TimePickerConfig` for either
the `DatePicker` or the `DateRangePicker` modules.


# Types

@docs PickerType

-}


{-| Describes the different _**picker types**_ along with their _**stepping function**_.

    -- An `Hours` and `Minutes` picker. The `Hours` part
    -- will increment / decrement their value by 1 whereas
    -- the `Minutes` will increment / decrement by 5.
    HH_MM { hoursStep = 1, minutesStep = 5 }

    -- An `Hours`, `Minutes` and `Seconds` picker.
    -- The `Hours` and `Minutes` will increment / decrement
    -- their values by 1 whereas the `Seconds` will
    -- increment / decrement by 10.
    HH_MM_SS { hoursStep = 1, minutesStep = 1, secondsStep = 10 }

-}
type PickerType
    = HH { hoursStep : Int }
    | HH_MM { hoursStep : Int, minutesStep : Int }
    | HH_MM_SS { hoursStep : Int, minutesStep : Int, secondsStep : Int }
    | HH_MM_SS_MMMM { hoursStep : Int, minutesStep : Int, secondsStep : Int, millisecondsStep : Int }

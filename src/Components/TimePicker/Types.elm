module Components.TimePicker.Types exposing
    ( PickerType(..)
    , TimeParts(..)
    )

{-| This module contains the `Public types` that can be used by the consumers.
-}


{-| A type that describes the different parts of a `Time`
-}
type TimeParts
    = Hours
    | Minutes
    | Seconds
    | Milliseconds


{-| Describes different picker types.
-}
type PickerType
    = HH { hoursStep : Int }
    | HH_MM { hoursStep : Int, minutesStep : Int }
    | HH_MM_SS { hoursStep : Int, minutesStep : Int, secondsStep : Int }
    | HH_MM_SS_MMMM { hoursStep : Int, minutesStep : Int, secondsStep : Int, millisecondsStep : Int }

module TimePicker.Internal.Update exposing
    ( InternalModel
    , Model(..)
    , Msg(..)
    , TimeParts(..)
    )

import Clock
import TimePicker.Types exposing (PickerType)


{-| The Internal messages that are being used by the TimePicker component.
-}
type Msg
    = InputHandler TimeParts String
    | Update TimeParts String
    | Increment TimeParts
    | Decrement TimeParts


{-| The TimePicker Model
-}
type Model
    = Model InternalModel


type alias InternalModel =
    { time : Clock.Time
    , pickerType : PickerType
    , hours : String
    , minutes : String
    , seconds : String
    , milliseconds : String
    }


{-| A type that describes the different parts of a `Time`
-}
type TimeParts
    = Hours
    | Minutes
    | Seconds
    | Milliseconds

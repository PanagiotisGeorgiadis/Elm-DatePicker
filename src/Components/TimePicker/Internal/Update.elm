module Components.TimePicker.Internal.Update exposing
    ( InternalModel
    , Model(..)
    , Msg(..)
    )

import Clock
import Components.TimePicker.Types exposing (PickerType, TimeParts)


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

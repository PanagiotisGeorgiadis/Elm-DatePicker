module Components.DatePicker.Internal.Update exposing
    ( Model(..)
    , Msg(..)
    , TimePickerState(..)
    , updatePrimaryDate
    )

import Components.DatePicker.Types exposing (DateLimit, TimePickerConfig, ViewType)
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)


{-| The `DateRangePicker Model`.
-}
type Model
    = Model
        { today : DateTime
        , viewType : ViewType
        , primaryDate : DateTime
        , dateLimit : DateLimit
        , selectedDate : Maybe DateTime
        , timePicker : TimePickerState
        }


{-| A representation of the TimePickerState.

    NoTimePickers -- The TimePickerConfig had a value of Nothing when passed on the initialisation function.

    NotInitialised config -- The TimePickerConfig had a value of (Just config) but the user hasn't selected a `dateRange` yet.

    TimePickers -- The TimePickers state.

-}
type TimePickerState
    = NoTimePicker
    | NotInitialised TimePickerConfig
    | TimePicker { timePicker : TimePicker.Model, pickerTitle : String }


{-| The Internal messages that are being used by the DateRangePicker component.
-}
type Msg
    = PreviousMonth
    | NextMonth
    | SelectDate DateTime
    | MoveToToday
    | InitialiseTimePicker
    | TimePickerMsg TimePicker.Msg


updatePrimaryDate : DateTime -> Model -> Model
updatePrimaryDate dt (Model model) =
    Model { model | primaryDate = dt }

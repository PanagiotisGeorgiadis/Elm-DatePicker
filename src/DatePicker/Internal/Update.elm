module DatePicker.Internal.Update exposing
    ( Model(..)
    , Msg(..)
    , TimePickerState(..)
    , updatePrimaryDate
    )

import DatePicker.Types exposing (DateLimit, TimePickerConfig, ViewType)
import DateTime exposing (DateTime)
import TimePicker.Update as TimePicker


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

    NoTimePickers -- The TimePickerConfig had a value of Nothing when passed on the initialise function.

    NotInitialised config -- The TimePickerConfig had a value of (Just config) but the user hasn't selected a `dateRange` yet.

    TimePickers -- The TimePickers state.

-}
type TimePickerState
    = NoTimePicker
    | NotInitialised TimePickerConfig
    | TimePicker { timePicker : TimePicker.Model, pickerTitle : String }


{-| The DatePicker module's internal messages.
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

module DatePicker.Internal.Update exposing
    ( Model(..)
    , Msg(..)
    , TimePickerState(..)
    , updatePrimaryDate
    )

import DatePicker.I18n exposing (I18n)
import DatePicker.Types exposing (DateLimit, ViewType)
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
        , i18n : I18n
        }


{-| A representation of the TimePickerState.

    NoTimePicker -- The TimePickerConfig had a value of Nothing when passed on the initialise function.

    TimePicker -- The TimePicker state.

-}
type TimePickerState
    = NoTimePicker
    | TimePicker { timePicker : TimePicker.Model, pickerTitle : String }


{-| The DatePicker module's internal messages.
-}
type Msg
    = PreviousMonth
    | NextMonth
    | SelectDate DateTime
    | MoveToToday
    | TimePickerMsg TimePicker.Msg


updatePrimaryDate : DateTime -> Model -> Model
updatePrimaryDate dt (Model model) =
    Model { model | primaryDate = dt }

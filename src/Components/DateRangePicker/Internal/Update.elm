module Components.DateRangePicker.Internal.Update exposing
    ( DateRange(..)
    , DateRangeOffset(..)
    , InternalViewType(..)
    , Msg(..)
    , SelectionType(..)
    , TimePickerState(..)
    )

import Clock
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)


{-| DateRangeOffset is being used to ensure that the `dateRange` that the user will
select, is of a certain length. In case we don't care about a minimum date range length we
use NoOffset.

Example:

    minDateRangeLength = 3
    selectedDate = 1 Jan 2019.
    invalidDates = [ 31 Dec 2018, 2 Jan 2019 ]
    minimumDateRanges =
        [ [ 1 Jan 2019
          , 2 Jan 2019
          , 3 Jan 2019
          ]
        , [ 30 Dec 2019
          , 31 Dec 2019
          , 1 Jan 2019
          ]
        ]

-}
type DateRangeOffset
    = Offset { invalidDates : List DateTime, minDateRangeLength : Int }
    | NoOffset


{-| Describes the DateRangePicker's dateRange state.

    NoneSelected -- User hasn't selected any dates yet.

    StartDateSelected -- User has only selected the start date.

    BothSelected (Visually start end) -- User has selected the `start date` and is hovering over an `end date`.

    BothSelected (Chosen start end) -- User has selected both the `start` and `end` dates.

-}
type DateRange
    = NoneSelected
    | StartDateSelected DateTime
    | BothSelected SelectionType


{-| The type of the `dateRange` selection. If the type is set to `Visually` it means that
the user has hovered over a `dateRange end date` but they haven't selected it yet. `Chosen` means
that the user has fully selected a dateRange.
-}
type SelectionType
    = Visually DateTime DateTime
    | Chosen DateTime DateTime


{-| Internal view type. The only valid ViewType combinations would be:

    Single, CalendarView
    Double, CalendarView
    Double, ClockView

-}
type InternalViewType
    = CalendarView
    | ClockView


{-| A representation of the TimePickerState.

    NoTimePickers -- The TimePickerConfig had a value of Nothing when passed on the initialisation function.

    NotInitialised config -- The TimePickerConfig had a value of (Just config) but the user hasn't selected a `dateRange` yet.

    TimePickers -- The TimePickers state.

-}
type TimePickerState
    = NoTimePickers
    | NotInitialised TimePickerConfig
    | TimePickers { startPicker : TimePicker.Model, endPicker : TimePicker.Model, pickerTitles : { start : String, end : String }, mirrorTimes : Bool }


{-| Duplicated the "original" `TimePickerConfig` here because its being used by the
`TimePickerState` but we also want to expose its properties for the documentation
of the package.
-}
type alias TimePickerConfig =
    { pickerType : TimePicker.PickerType
    , defaultTime : Clock.Time
    , pickerTitles : { start : String, end : String }
    , mirrorTimes : Bool
    }


{-| The Internal messages that are being used by the DateRangePicker component.
-}
type Msg
    = PreviousMonth
    | NextMonth
    | SelectDate DateTime
    | UpdateVisualSelection DateTime
    | ResetVisualSelection
    | ShowClockView
    | ShowCalendarView
    | InitialiseTimePickers
    | ToggleTimeMirroring
    | SyncTimePickers DateTime
    | RangeStartPickerMsg TimePicker.Msg
    | RangeEndPickerMsg TimePicker.Msg
    | MoveToToday



-- {-| Updates the date range offset in the Model if it does
-- -}

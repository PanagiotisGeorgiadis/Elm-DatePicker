module DateRangePicker.Internal.Update exposing
    ( DateRange(..)
    , DateRangeOffset(..)
    , Model(..)
    , Msg(..)
    , SelectionType(..)
    , TimePickerState(..)
    , ViewType(..)
    , showClockView
    , updateDateRangeOffset
    , updatePrimaryDate
    )

import Clock
import DateRangePicker.Types exposing (DateLimit(..), TimePickerConfig)
import DateTime exposing (DateTime)
import TimePicker.Update as TimePicker
import Utils.Actions exposing (fireAction)
import Utils.DateTime as DateTime


{-| The Internal ViewType which combines both the `display mode` and the type
of the view that's active.
-}
type ViewType
    = SingleCalendar
    | DoubleCalendar
    | DoubleTimePicker


{-| DateRangeOffset is being used to ensure that the `dateRange` that the user will
select, is of a certain length. In case we don't care about a minimum date range length we
use NoOffset.

Example:

    selectedDate = 1 Jan 2019.

    minDateRangeLength = 3
    invalidDates = [ 31 Dec 2018, 2 Jan 2019 ]

    minimumDateRanges =
        [ [ 1 Jan 2019, 2 Jan 2019, 3 Jan 2019 ] -- First possible selection
        , [ 30 Dec 2019, 31 Dec 2019, 1 Jan 2019 ] -- Second possible selection
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


{-| A representation of the TimePickerState.

    NoTimePickers -- The TimePickerConfig had a value of Nothing when passed on the initialisation function.

    TimePickers -- The TimePickers state.

-}
type TimePickerState
    = NoTimePickers
    | TimePickers { startPicker : TimePicker.Model, endPicker : TimePicker.Model, pickerTitles : { start : String, end : String }, mirrorTimes : Bool }


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
    | ToggleTimeMirroring
    | SyncTimePickers Clock.Time
    | RangeStartPickerMsg TimePicker.Msg
    | RangeEndPickerMsg TimePicker.Msg
    | MoveToToday


{-| The `DateRangePicker Model`.
-}
type Model
    = Model InternalModel


type alias InternalModel =
    { viewType : ViewType
    , today : DateTime
    , primaryDate : DateTime
    , range : DateRange
    , dateLimit : DateLimit
    , dateRangeOffset : DateRangeOffset
    , timePickers : TimePickerState
    }


{-| Updates the DateRangeOffset on the given model, if a DateRangeOffset has
been specified by the consumer. The dateRangeOffset is consists of a list of
invalid dates and the minimum date range length.
-}
updateDateRangeOffset : InternalModel -> InternalModel
updateDateRangeOffset ({ range, dateRangeOffset } as model) =
    case dateRangeOffset of
        Offset { minDateRangeLength } ->
            let
                offsetConfig invalidDates =
                    { minDateRangeLength = minDateRangeLength, invalidDates = invalidDates }
            in
            case range of
                StartDateSelected start ->
                    let
                        isNotEqualToStartDate d =
                            DateTime.compareDates start d /= EQ

                        -- Get all the future dates that are too close to the range start date.
                        -- Example for minDateRangeLength == 4 and startDate == 26 Aug 2019
                        -- [ 27 Aug 2019, 28 Aug 2019 ] will be the disabled dates because
                        -- we want a minimum length of 4 days which will be [ 26, 27, 28, 29 ]
                        -- Note that 29 Aug 2019 will be the first available date to choose ( from the future dates ).
                        invalidFutureDates =
                            List.filter isNotEqualToStartDate <|
                                List.reverse <|
                                    List.drop 1 <|
                                        List.reverse <|
                                            DateTime.getDateRange start (DateTime.incrementDays (minDateRangeLength - 1) start) Clock.midnight

                        -- Get all the past dates that are too close to the range start date.
                        -- Example for minDateRangeLength == 4 and startDate == 26 Aug 2019
                        -- [ 24 Aug 2019, 25 Aug 2019 ] will be the disabled dates because
                        -- we want a minimum length of 4 days which will be [ 23, 24, 25, 26 ]
                        -- Note that 23 Aug 2019 will be the first available date to choose ( from the past dates ).
                        invalidPastDates =
                            List.filter isNotEqualToStartDate <|
                                List.reverse <|
                                    List.drop 1 <|
                                        DateTime.getDateRange start (DateTime.decrementDays (minDateRangeLength - 1) start) Clock.midnight

                        invalidDates =
                            invalidFutureDates ++ invalidPastDates
                    in
                    { model | dateRangeOffset = Offset (offsetConfig invalidDates) }

                _ ->
                    { model | dateRangeOffset = Offset (offsetConfig []) }

        NoOffset ->
            model


updatePrimaryDate : DateTime -> Model -> Model
updatePrimaryDate dt (Model model) =
    Model { model | primaryDate = dt }


showClockView : InternalModel -> Cmd Msg
showClockView { viewType, timePickers } =
    case ( viewType, timePickers ) of
        ( DoubleCalendar, TimePickers _ ) ->
            fireAction ShowClockView

        _ ->
            Cmd.none

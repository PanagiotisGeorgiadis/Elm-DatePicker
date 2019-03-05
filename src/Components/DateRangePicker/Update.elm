module Components.DateRangePicker.Update exposing
    ( DateLimit(..)
    , DateRange(..)
    , DateRangeOffset(..)
    , InternalViewType(..)
    , Model
    , Msg(..)
    , SelectionType(..)
    , TimePickerConfig
    , TimePickerState(..)
    , ViewType(..)
    , initialise
    , update
    )

import Clock
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)
import Time
import Utils.Actions exposing (fireAction)
import Utils.DateTime as DateTime


{-| To be exposed
-}
type ViewType
    = Single
    | Double


{-| Internal
-}
type DateRangeOffset
    = Offset { invalidDates : List DateTime, minDateRangeLength : Int }
    | NoOffset


{-| Exposed
-}
type alias OffsetConfig =
    { minDateRangeLength : Int }


{-| To be exposed
-}
type DateLimit
    = DateLimit { minDate : DateTime, maxDate : DateTime }
    | NoLimit { disablePastDates : Bool }


{-| Internal
-}
type DateRange
    = NoneSelected
    | StartDateSelected DateTime
    | BothSelected SelectionType


{-| Internal
-}
type SelectionType
    = Visually DateTime DateTime
    | Chosen DateTime DateTime


{-| Internal
-}
type InternalViewType
    = CalendarView
    | ClockView


{-| Exposed
-}
type alias TimePickerConfig =
    { pickerType : TimePicker.PickerType
    , defaultTime : Clock.Time
    , mirrorTimes : Bool
    }


{-| Internal
-}
type TimePickerState
    = NoTimePickers
    | NotInitialised TimePickerConfig
    | TimePickers { mirrorTimes : Bool, startPicker : TimePicker.Model, endPicker : TimePicker.Model }


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , range : DateRange
    , dateLimit : DateLimit
    , dateRangeOffset : DateRangeOffset
    , internalViewType : InternalViewType
    , timePickers : TimePickerState
    }


type alias CalendarConfig =
    { today : DateTime
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , dateRangeOffset : Maybe OffsetConfig
    }


initialise : ViewType -> CalendarConfig -> Maybe TimePickerConfig -> Model
initialise viewType { today, primaryDate, dateLimit, dateRangeOffset } timePickerConfig =
    let
        primaryDate_ =
            case dateLimit of
                DateLimit { minDate } ->
                    minDate

                _ ->
                    primaryDate
    in
    { viewType = viewType
    , internalViewType = CalendarView

    --
    , today = today
    , primaryDate = primaryDate_
    , range = NoneSelected
    , dateLimit = dateLimit
    , dateRangeOffset =
        case dateRangeOffset of
            Just { minDateRangeLength } ->
                Offset { minDateRangeLength = minDateRangeLength, invalidDates = [] }

            Nothing ->
                NoOffset

    --
    , timePickers =
        case timePickerConfig of
            Just config ->
                NotInitialised config

            Nothing ->
                NoTimePickers
    }


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PreviousMonth ->
            ( { model | primaryDate = DateTime.decrementMonth model.primaryDate }
            , Cmd.none
            )

        NextMonth ->
            ( { model | primaryDate = DateTime.incrementMonth model.primaryDate }
            , Cmd.none
            )

        SelectDate date ->
            let
                updateModel start =
                    case DateTime.compareDates start date of
                        EQ ->
                            ( { model | range = NoneSelected }
                            , Cmd.none
                            )

                        LT ->
                            ( { model | range = BothSelected (Chosen start date) }
                            , fireAction InitialiseTimePickers
                            )

                        GT ->
                            ( { model | range = BothSelected (Chosen date start) }
                            , fireAction InitialiseTimePickers
                            )

                ( model_, cmd ) =
                    case model.range of
                        StartDateSelected start ->
                            updateModel start

                        BothSelected (Visually start end) ->
                            updateModel start

                        _ ->
                            ( { model | range = StartDateSelected date }
                            , Cmd.none
                            )
            in
            ( updateDateRangeOffset model_
            , cmd
            )

        UpdateVisualSelection date ->
            let
                updateModel start =
                    case DateTime.compareDates start date of
                        EQ ->
                            { model | range = StartDateSelected start }

                        _ ->
                            { model | range = BothSelected (Visually start date) }
            in
            case model.range of
                StartDateSelected start ->
                    ( updateModel start
                    , Cmd.none
                    )

                BothSelected (Visually start _) ->
                    ( updateModel start
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        ResetVisualSelection ->
            case model.range of
                BothSelected (Visually start _) ->
                    ( { model | range = StartDateSelected start }
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        ShowClockView ->
            ( { model | internalViewType = ClockView }
            , Cmd.none
            )

        ShowCalendarView ->
            ( { model | internalViewType = CalendarView }
            , Cmd.none
            )

        InitialiseTimePickers ->
            case model.timePickers of
                NotInitialised { pickerType, defaultTime, mirrorTimes } ->
                    case model.range of
                        BothSelected (Chosen start end) ->
                            let
                                timePicker =
                                    TimePicker.initialise { time = defaultTime, pickerType = pickerType }
                            in
                            ( { model
                                | timePickers =
                                    TimePickers
                                        { startPicker = timePicker
                                        , endPicker = timePicker
                                        , mirrorTimes = mirrorTimes
                                        }
                              }
                            , Cmd.none
                            )

                        _ ->
                            ( model
                            , Cmd.none
                            )

                _ ->
                    ( model
                    , Cmd.none
                    )

        ToggleTimeMirroring ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    ( { model
                        | timePickers =
                            TimePickers { startPicker = startPicker, endPicker = endPicker, mirrorTimes = not mirrorTimes }
                      }
                    , fireAction (SyncTimePickers start)
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        SyncTimePickers dateTime ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    if mirrorTimes == True then
                        let
                            time =
                                DateTime.getTime dateTime

                            ( updateFn, timePickerUpdateFn ) =
                                ( DateTime.setTime time
                                , TimePicker.updateDisplayTime time
                                )
                        in
                        ( { model
                            | range = BothSelected (Chosen (updateFn start) (updateFn end))
                            , timePickers =
                                TimePickers
                                    { startPicker = timePickerUpdateFn startPicker
                                    , endPicker = timePickerUpdateFn endPicker
                                    , mirrorTimes = mirrorTimes
                                    }
                          }
                        , Cmd.none
                        )

                    else
                        ( model
                        , Cmd.none
                        )

                _ ->
                    ( model
                    , Cmd.none
                    )

        RangeStartPickerMsg subMsg ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg startPicker

                        ( range, cmd ) =
                            case extMsg of
                                TimePicker.UpdatedTime time ->
                                    let
                                        updatedStart =
                                            DateTime.setTime time start
                                    in
                                    ( BothSelected (Chosen updatedStart end)
                                    , fireAction (SyncTimePickers updatedStart)
                                    )

                                _ ->
                                    ( model.range
                                    , Cmd.none
                                    )
                    in
                    ( { model
                        | range = range
                        , timePickers =
                            TimePickers
                                { startPicker = subModel
                                , endPicker = endPicker
                                , mirrorTimes = mirrorTimes
                                }
                      }
                    , Cmd.batch
                        [ Cmd.map RangeStartPickerMsg subCmd
                        , cmd
                        ]
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        RangeEndPickerMsg subMsg ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg endPicker

                        ( range, cmd ) =
                            case extMsg of
                                TimePicker.UpdatedTime time ->
                                    let
                                        updatedEnd =
                                            DateTime.setTime time end
                                    in
                                    ( BothSelected (Chosen start updatedEnd)
                                    , fireAction (SyncTimePickers updatedEnd)
                                    )

                                _ ->
                                    ( model.range
                                    , Cmd.none
                                    )
                    in
                    ( { model
                        | range = range
                        , timePickers =
                            TimePickers
                                { startPicker = startPicker
                                , endPicker = subModel
                                , mirrorTimes = mirrorTimes
                                }
                      }
                    , Cmd.batch
                        [ Cmd.map RangeEndPickerMsg subCmd
                        , cmd
                        ]
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        MoveToToday ->
            ( { model | primaryDate = DateTime.setDate (DateTime.getDate model.today) model.primaryDate }
            , Cmd.none
            )


updateDateRangeOffset : Model -> Model
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
                        -- Get all the future dates that are too close to the range start date.
                        -- Example for minDateRangeLength == 4 and startDate == 26 Aug 2019
                        -- [ 27 Aug 2019, 28 Aug 2019 ] will be the disabled dates because
                        -- we want a minimum length of 4 days which will be [ 26, 27, 28, 29 ]
                        -- Note that 29 Aug 2019 will be the first available date to choose ( from the future dates ).
                        invalidFutureDates =
                            List.filter ((/=) start) <|
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
                            List.filter ((/=) start) <|
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

module Components.DateRangePicker.Update exposing
    ( DateLimit(..)
    , DateRange(..)
    , DateRangeOffset(..)
    , InternalViewType(..)
    , Model
    , Msg(..)
    , ViewType(..)
    , initialise
    , update
    )

import Clock
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)
import Models.Calendar as Calendar
import Task
import Time


type ViewType
    = Single
    | Double


type DateRangeOffset
    = Offset OffsetConfig
    | NoOffset


type alias OffsetConfig =
    { invalidDates : List DateTime
    , minDateRangeLength : Int
    }


type DateLimit
    = DateLimit DateLimitation
    | NoLimit NoLimitConfig


type alias DateLimitation =
    { minDate : DateTime
    , maxDate : DateTime
    }


type alias NoLimitConfig =
    { disablePastDates : Bool
    }



-- type Shadowing
--     = Enabled (Maybe DateTime)
--     | Disabled


type DateRange
    = NoneSelected
    | StartDateSelected DateTime
      -- | BothSelectedTemp
    | BothSelected DateTime DateTime


type InternalViewType
    = CalendarView
    | ClockView


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , range : DateRange
    , shadowRangeEnd : Maybe DateTime

    -- , showOnHover : Shadowing -- TODO: Think about that ?
    , dateLimit : DateLimit
    , dateRangeOffset : DateRangeOffset

    --
    , internalViewType : InternalViewType

    --
    , pickerType : TimePicker.PickerType
    , mirrorTimes : Bool
    , rangeStartTimePicker : Maybe TimePicker.Model
    , rangeEndTimePicker : Maybe TimePicker.Model
    }


type alias DateRangeConfig =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , pickerType : TimePicker.PickerType
    , mirrorTimes : Bool

    -- , showOnHover : Shadowing
    }


initialise : DateRangeConfig -> Model
initialise { today, viewType, primaryDate, dateLimit, mirrorTimes, pickerType } =
    let
        primaryDate_ =
            case dateLimit of
                DateLimit { minDate } ->
                    minDate

                _ ->
                    primaryDate
    in
    { today = today
    , viewType = viewType
    , primaryDate = primaryDate_
    , range = NoneSelected
    , shadowRangeEnd = Nothing
    , dateLimit = dateLimit
    , dateRangeOffset = Offset { minDateRangeLength = 4, invalidDates = [] }

    --
    , internalViewType = CalendarView

    --
    , pickerType = pickerType
    , mirrorTimes = mirrorTimes
    , rangeStartTimePicker = Nothing
    , rangeEndTimePicker = Nothing
    }


type Msg
    = NoOp
    | PreviousMonth
    | NextMonth
    | SelectDate DateTime
    | DateHoverDetected DateTime
    | ResetShadowDateRange
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
        NoOp ->
            ( model
            , Cmd.none
            )

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
                model_ =
                    { model | shadowRangeEnd = Nothing }

                ( updatedModel, cmd ) =
                    case model.range of
                        NoneSelected ->
                            ( { model | range = StartDateSelected date }
                            , Cmd.none
                            )

                        StartDateSelected startDate ->
                            case DateTime.compareDates startDate date of
                                EQ ->
                                    ( { model | range = NoneSelected }
                                    , Cmd.none
                                    )

                                LT ->
                                    ( { model | range = BothSelected startDate date }
                                    , Task.perform (\_ -> InitialiseTimePickers) (Task.succeed ())
                                    )

                                GT ->
                                    ( { model | range = BothSelected date startDate }
                                    , Task.perform (\_ -> InitialiseTimePickers) (Task.succeed ())
                                    )

                        BothSelected _ _ ->
                            ( { model | range = StartDateSelected date }
                            , Cmd.none
                            )
            in
            ( updateDateRangeOffset updatedModel
            , cmd
            )

        DateHoverDetected date ->
            case model.range of
                StartDateSelected start ->
                    ( { model | shadowRangeEnd = Just date }
                    , Cmd.none
                    )

                _ ->
                    ( { model | shadowRangeEnd = Nothing }
                    , Cmd.none
                    )

        ResetShadowDateRange ->
            ( { model | shadowRangeEnd = Nothing }
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
            case model.range of
                BothSelected start end ->
                    let
                        initialiseTimePicker dateTime =
                            TimePicker.initialise
                                { time = DateTime.getTime dateTime
                                , pickerType = model.pickerType
                                }
                    in
                    ( { model
                        | rangeStartTimePicker = Just (initialiseTimePicker start)
                        , rangeEndTimePicker = Just (initialiseTimePicker end)
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        ToggleTimeMirroring ->
            ( { model | mirrorTimes = not model.mirrorTimes }
            , case model.range of
                BothSelected start end ->
                    Task.perform (\_ -> SyncTimePickers start) (Task.succeed ())

                _ ->
                    Cmd.none
            )

        SyncTimePickers dateTime ->
            case ( model.range, model.mirrorTimes ) of
                ( BothSelected start end, True ) ->
                    let
                        time =
                            DateTime.getTime dateTime

                        ( updateFn, timePickerUpdateFn ) =
                            ( DateTime.setTime time
                            , Maybe.map (TimePicker.updateDisplayTime time)
                            )
                    in
                    ( { model
                        | range = BothSelected (updateFn start) (updateFn end)
                        , rangeStartTimePicker = timePickerUpdateFn model.rangeStartTimePicker
                        , rangeEndTimePicker = timePickerUpdateFn model.rangeEndTimePicker
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model
                    , Cmd.none
                    )

        RangeStartPickerMsg subMsg ->
            case model.rangeStartTimePicker of
                Just timePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg timePickerModel

                        ( range, cmd ) =
                            case ( extMsg, model.range ) of
                                ( TimePicker.UpdatedTime time, BothSelected start end ) ->
                                    let
                                        updatedStart =
                                            DateTime.setTime time start
                                    in
                                    ( BothSelected updatedStart end
                                    , Task.perform (\_ -> SyncTimePickers updatedStart) (Task.succeed ())
                                    )

                                _ ->
                                    ( model.range
                                    , Cmd.none
                                    )
                    in
                    ( { model
                        | range = range
                        , rangeStartTimePicker = Just subModel
                      }
                    , Cmd.batch
                        [ Cmd.map RangeStartPickerMsg subCmd
                        , cmd
                        ]
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    )

        RangeEndPickerMsg subMsg ->
            case model.rangeEndTimePicker of
                Just timePickerModel ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg timePickerModel

                        ( range, cmd ) =
                            case ( extMsg, model.range ) of
                                ( TimePicker.UpdatedTime time, BothSelected start end ) ->
                                    let
                                        updatedEnd =
                                            DateTime.setTime time end
                                    in
                                    ( BothSelected start updatedEnd
                                    , Task.perform (\_ -> SyncTimePickers updatedEnd) (Task.succeed ())
                                    )

                                _ ->
                                    ( model.range
                                    , Cmd.none
                                    )
                    in
                    ( { model
                        | range = range
                        , rangeEndTimePicker = Just subModel
                      }
                    , Cmd.batch
                        [ Cmd.map RangeEndPickerMsg subCmd
                        , cmd
                        ]
                    )

                Nothing ->
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
                                            DateTime.getDateRange start (Calendar.incrementDays (minDateRangeLength - 1) start) Clock.midnight

                        -- Get all the past dates that are too close to the range start date.
                        -- Example for minDateRangeLength == 4 and startDate == 26 Aug 2019
                        -- [ 24 Aug 2019, 25 Aug 2019 ] will be the disabled dates because
                        -- we want a minimum length of 4 days which will be [ 23, 24, 25, 26 ]
                        -- Note that 23 Aug 2019 will be the first available date to choose ( from the past dates ).
                        invalidPastDates =
                            List.filter ((/=) start) <|
                                List.reverse <|
                                    List.drop 1 <|
                                        DateTime.getDateRange start (Calendar.decrementDays (minDateRangeLength - 1) start) Clock.midnight

                        invalidDates =
                            invalidFutureDates ++ invalidPastDates
                    in
                    { model
                        | dateRangeOffset = Offset (OffsetConfig invalidDates minDateRangeLength)
                    }

                _ ->
                    { model
                        | dateRangeOffset = Offset (OffsetConfig [] minDateRangeLength)
                    }

        NoOffset ->
            model

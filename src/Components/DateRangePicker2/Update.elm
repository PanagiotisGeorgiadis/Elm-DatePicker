module Components.DateRangePicker2.Update exposing
    ( DateLimit(..)
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


type InternalViewType
    = CalendarView
    | ClockView


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , rangeStart : Maybe DateTime
    , rangeEnd : Maybe DateTime
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
    , rangeStart = Nothing
    , rangeEnd = Nothing
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
    | SyncTimePickers (Maybe DateTime)
    | RangeStartPickerMsg TimePicker.Msg
    | RangeEndPickerMsg TimePicker.Msg


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

                updatedModel =
                    case ( model.rangeStart, model.rangeEnd ) of
                        ( Just start, Nothing ) ->
                            -- Date Range Complete
                            case DateTime.compareDates start date of
                                LT ->
                                    -- Normal case.
                                    { model_ | rangeEnd = Just date }

                                EQ ->
                                    -- Cancels out the selected date.
                                    { model_ | rangeStart = Nothing, rangeEnd = Nothing }

                                GT ->
                                    -- Reversed case. ie. the user selected the rangeEnd first.
                                    { model_ | rangeStart = Just date, rangeEnd = Just start }

                        ( Nothing, Just end ) ->
                            -- Fixing some imposible state
                            { model_ | rangeStart = Just date, rangeEnd = Nothing }

                        ( Just start, Just end ) ->
                            -- Resetting the date range here
                            { model_ | rangeStart = Just date, rangeEnd = Nothing }

                        ( Nothing, Nothing ) ->
                            -- Starting the date range process.
                            { model_ | rangeStart = Just date }
            in
            ( updateDateRangeOffset updatedModel
            , case ( updatedModel.rangeStart, updatedModel.rangeEnd ) of
                ( Just start, Just end ) ->
                    Task.perform (\_ -> InitialiseTimePickers) (Task.succeed ())

                _ ->
                    Cmd.none
            )

        DateHoverDetected date ->
            case ( model.rangeStart, model.rangeEnd ) of
                ( Just start, Nothing ) ->
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
            case ( model.rangeStart, model.rangeEnd ) of
                ( Just start, Just end ) ->
                    let
                        initialiseTimePicker dateTime =
                            TimePicker.initialise
                                { time = DateTime.getTime dateTime
                                , pickerType = model.pickerType
                                , stepping =
                                    { hours = TimePicker.Step 1
                                    , minutes = TimePicker.Step 5
                                    , seconds = TimePicker.NoStep
                                    , milliseconds = TimePicker.NoStep
                                    }
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
            , Task.perform (\_ -> SyncTimePickers model.rangeStart) (Task.succeed ())
            )

        SyncTimePickers dt ->
            case ( dt, model.mirrorTimes ) of
                ( Just dateTime, True ) ->
                    let
                        time =
                            DateTime.getTime dateTime

                        ( updateFn, timePickerUpdateFn ) =
                            ( Maybe.map (DateTime.setTime time)
                            , Maybe.map (TimePicker.updateDisplayTime time)
                            )
                    in
                    ( { model
                        | rangeStart = updateFn model.rangeStart
                        , rangeStartTimePicker = timePickerUpdateFn model.rangeStartTimePicker
                        , rangeEnd = updateFn model.rangeEnd
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

                        ( rangeStart, cmd ) =
                            case extMsg of
                                TimePicker.UpdatedTime time ->
                                    let
                                        updatedValue =
                                            Maybe.map (DateTime.setTime time) model.rangeStart
                                    in
                                    ( updatedValue
                                    , Task.perform (\_ -> SyncTimePickers updatedValue) (Task.succeed ())
                                    )

                                TimePicker.None ->
                                    ( model.rangeStart
                                    , Cmd.none
                                    )
                    in
                    ( { model
                        | rangeStart = rangeStart
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

                        ( rangeEnd, cmd ) =
                            case extMsg of
                                TimePicker.UpdatedTime time ->
                                    let
                                        updatedValue =
                                            Maybe.map (DateTime.setTime time) model.rangeEnd
                                    in
                                    ( updatedValue
                                    , Task.perform (\_ -> SyncTimePickers updatedValue) (Task.succeed ())
                                    )

                                TimePicker.None ->
                                    ( model.rangeEnd
                                    , Cmd.none
                                    )
                    in
                    ( { model
                        | rangeEnd = rangeEnd
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


updateDateRangeOffset : Model -> Model
updateDateRangeOffset ({ rangeStart, rangeEnd, dateRangeOffset } as model) =
    case dateRangeOffset of
        Offset { minDateRangeLength } ->
            case ( rangeStart, rangeEnd ) of
                ( Just start, Nothing ) ->
                    let
                        -- Get all the future dates that are too close to the range start date.
                        -- Example for minDateRangeLength == 4 and rangeStart == 26 Aug 2019
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
                        -- Example for minDateRangeLength == 4 and rangeStart == 26 Aug 2019
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

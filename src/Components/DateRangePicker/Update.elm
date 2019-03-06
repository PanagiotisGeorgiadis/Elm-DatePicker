module Components.DateRangePicker.Update exposing
    ( DateLimit(..)
    , ExtMsg(..)
    , Model
    , Msg(..)
    , TimePickerConfig
    , ViewType(..)
    , initialise
    , update
    )

import Clock
import Components.DateRangePicker.Internal.Update as Internal
    exposing
        ( DateRange(..)
        , DateRangeOffset(..)
        , InternalViewType(..)
        , SelectionType(..)
        , TimePickerState(..)
        )
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)
import Time
import Utils.Actions exposing (fireAction)
import Utils.DateTime as DateTime


{-| Expose
-}
type ViewType
    = Single
    | Double


{-| Expose
-}
type DateLimit
    = DateLimit { minDate : DateTime, maxDate : DateTime }
    | NoLimit { disablePastDates : Bool }


{-| Expose
-}
type alias CalendarConfig =
    { today : DateTime
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , dateRangeOffset : Maybe { minDateRangeLength : Int }
    }


{-| Expose
-}
type alias TimePickerConfig =
    Internal.TimePickerConfig


{-| Expose
-}
type alias Model =
    { viewType : ViewType
    , internalViewType : InternalViewType
    , today : DateTime
    , primaryDate : DateTime
    , range : DateRange
    , dateLimit : DateLimit
    , dateRangeOffset : DateRangeOffset
    , timePickers : TimePickerState
    }


{-| Expose
-}
initialise : ViewType -> CalendarConfig -> Maybe TimePickerConfig -> Model
initialise viewType { today, primaryDate, dateLimit, dateRangeOffset } timePickerConfig =
    let
        updateTime dateTime =
            case timePickerConfig of
                Just { defaultTime } ->
                    DateTime.setTime defaultTime dateTime

                _ ->
                    dateTime

        primaryDate_ =
            case dateLimit of
                DateLimit { minDate } ->
                    updateTime minDate

                _ ->
                    updateTime primaryDate

        dateRangeOffset_ =
            case dateRangeOffset of
                Just { minDateRangeLength } ->
                    Offset { minDateRangeLength = minDateRangeLength, invalidDates = [] }

                Nothing ->
                    NoOffset

        timePickers =
            case timePickerConfig of
                Just config ->
                    NotInitialised config

                Nothing ->
                    NoTimePickers
    in
    { viewType = viewType
    , internalViewType = CalendarView
    , today = today
    , primaryDate = primaryDate_
    , range = NoneSelected
    , dateLimit = dateLimit
    , dateRangeOffset = dateRangeOffset_
    , timePickers = timePickers
    }


{-| Expose
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


type ExtMsg
    = None
    | DateRangeSelected (Maybe SelectedDateRange)


type alias SelectedDateRange =
    { startDate : DateTime
    , endDate : DateTime
    }


{-| Expose
-}
update : Msg -> Model -> ( Model, Cmd Msg, ExtMsg )
update msg model =
    case msg of
        PreviousMonth ->
            ( { model | primaryDate = DateTime.decrementMonth model.primaryDate }
            , Cmd.none
            , None
            )

        NextMonth ->
            ( { model | primaryDate = DateTime.incrementMonth model.primaryDate }
            , Cmd.none
            , None
            )

        SelectDate date ->
            let
                updateModel start =
                    case DateTime.compareDates start date of
                        EQ ->
                            ( { model | range = NoneSelected }
                            , Cmd.none
                            , DateRangeSelected Nothing
                            )

                        LT ->
                            ( { model | range = BothSelected (Chosen start date) }
                            , fireAction InitialiseTimePickers
                            , DateRangeSelected (Just { startDate = start, endDate = date })
                            )

                        GT ->
                            ( { model | range = BothSelected (Chosen date start) }
                            , fireAction InitialiseTimePickers
                            , DateRangeSelected (Just { startDate = date, endDate = start })
                            )

                ( model_, cmd, extMsg ) =
                    case model.range of
                        StartDateSelected start ->
                            updateModel start

                        BothSelected (Visually start end) ->
                            updateModel start

                        _ ->
                            ( { model | range = StartDateSelected date }
                            , Cmd.none
                            , None
                            )
            in
            ( updateDateRangeOffset model_
            , cmd
            , extMsg
            )

        UpdateVisualSelection date ->
            let
                updateModel start =
                    case DateTime.compareDates start date of
                        EQ ->
                            { model | range = StartDateSelected start }

                        _ ->
                            { model | range = BothSelected (Visually start date) }

                updatedModel =
                    case model.range of
                        StartDateSelected start ->
                            updateModel start

                        BothSelected (Visually start _) ->
                            updateModel start

                        _ ->
                            model
            in
            ( updatedModel
            , Cmd.none
            , None
            )

        ResetVisualSelection ->
            case model.range of
                BothSelected (Visually start _) ->
                    ( { model | range = StartDateSelected start }
                    , Cmd.none
                    , None
                    )

                _ ->
                    ( model
                    , Cmd.none
                    , None
                    )

        ShowClockView ->
            ( { model | internalViewType = ClockView }
            , Cmd.none
            , None
            )

        ShowCalendarView ->
            ( { model | internalViewType = CalendarView }
            , Cmd.none
            , None
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
                            , None
                            )

                        _ ->
                            ( model
                            , Cmd.none
                            , None
                            )

                _ ->
                    ( model
                    , Cmd.none
                    , None
                    )

        ToggleTimeMirroring ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    ( { model
                        | timePickers =
                            TimePickers { startPicker = startPicker, endPicker = endPicker, mirrorTimes = not mirrorTimes }
                      }
                    , fireAction (SyncTimePickers start)
                    , None
                    )

                _ ->
                    ( model
                    , Cmd.none
                    , None
                    )

        SyncTimePickers dateTime ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    if mirrorTimes == True then
                        let
                            time =
                                DateTime.getTime dateTime

                            timePickerUpdateFn =
                                TimePicker.updateDisplayTime time

                            ( updatedStartDate, updatedEndDate ) =
                                ( DateTime.setTime time start
                                , DateTime.setTime time end
                                )
                        in
                        ( { model
                            | range = BothSelected (Chosen updatedStartDate updatedEndDate)
                            , timePickers =
                                TimePickers
                                    { startPicker = timePickerUpdateFn startPicker
                                    , endPicker = timePickerUpdateFn endPicker
                                    , mirrorTimes = mirrorTimes
                                    }
                          }
                        , Cmd.none
                        , DateRangeSelected (Just { startDate = updatedStartDate, endDate = updatedEndDate })
                        )

                    else
                        ( model
                        , Cmd.none
                        , None
                        )

                _ ->
                    ( model
                    , Cmd.none
                    , None
                    )

        RangeStartPickerMsg subMsg ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg startPicker

                        ( range, cmd, externalMsg ) =
                            case extMsg of
                                TimePicker.UpdatedTime time ->
                                    let
                                        updatedStart =
                                            DateTime.setTime time start
                                    in
                                    ( BothSelected (Chosen updatedStart end)
                                    , fireAction (SyncTimePickers updatedStart)
                                    , DateRangeSelected (Just { startDate = updatedStart, endDate = end })
                                    )

                                _ ->
                                    ( model.range
                                    , Cmd.none
                                    , None
                                    )

                        timePickers =
                            TimePickers { startPicker = subModel, endPicker = endPicker, mirrorTimes = mirrorTimes }
                    in
                    ( { model
                        | range = range
                        , timePickers = timePickers
                      }
                    , Cmd.batch
                        [ Cmd.map RangeStartPickerMsg subCmd
                        , cmd
                        ]
                    , externalMsg
                    )

                _ ->
                    ( model
                    , Cmd.none
                    , None
                    )

        RangeEndPickerMsg subMsg ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg endPicker

                        ( range, cmd, externalMsg ) =
                            case extMsg of
                                TimePicker.UpdatedTime time ->
                                    let
                                        updatedEnd =
                                            DateTime.setTime time end
                                    in
                                    ( BothSelected (Chosen start updatedEnd)
                                    , fireAction (SyncTimePickers updatedEnd)
                                    , DateRangeSelected (Just { startDate = start, endDate = updatedEnd })
                                    )

                                _ ->
                                    ( model.range
                                    , Cmd.none
                                    , None
                                    )

                        timePickers =
                            TimePickers { startPicker = startPicker, endPicker = subModel, mirrorTimes = mirrorTimes }
                    in
                    ( { model
                        | range = range
                        , timePickers = timePickers
                      }
                    , Cmd.batch
                        [ Cmd.map RangeEndPickerMsg subCmd
                        , cmd
                        ]
                    , externalMsg
                    )

                _ ->
                    ( model
                    , Cmd.none
                    , None
                    )

        MoveToToday ->
            ( { model | primaryDate = DateTime.setDate (DateTime.getDate model.today) model.primaryDate }
            , Cmd.none
            , None
            )


{-| Internal
-}
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

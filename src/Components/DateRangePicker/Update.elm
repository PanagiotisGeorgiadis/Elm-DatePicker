module Components.DateRangePicker.Update exposing
    ( ExtMsg(..)
    , Model
    , Msg
    , initialise
    , update
    )

import Clock
import Components.DateRangePicker.Internal.Update as Internal
    exposing
        ( DateRange(..)
        , DateRangeOffset(..)
        , Model(..)
        , Msg(..)
        , SelectionType(..)
        , TimePickerState(..)
        )
import Components.DateRangePicker.Types
    exposing
        ( CalendarConfig
        , DateLimit(..)
        , TimePickerConfig
        , ViewType(..)
        )
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)
import Time
import Utils.Actions exposing (fireAction)
import Utils.DateTime as DateTime


{-| The `DateRangePicker Model`.
-}
type alias Model =
    Internal.Model


{-| The Internal messages that are being used by the DateRangePicker component.
-}
type alias Msg =
    Internal.Msg


{-| The External messages that are being used to transform information to the
parent component.
-}
type ExtMsg
    = None
    | DateRangeSelected (Maybe SelectedDateRange)


{-| The SelectedDateRange returned as a payload by the ExtMsg DateRangeSelected
-}
type alias SelectedDateRange =
    { startDate : DateTime
    , endDate : DateTime
    }


{-| The initialisation function for the `DateRangePicker` module.
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

        viewType_ =
            case viewType of
                Single ->
                    Internal.SingleCalendar

                Double ->
                    Internal.DoubleCalendar
    in
    Model
        { viewType = viewType_
        , today = today
        , primaryDate = primaryDate_
        , range = NoneSelected
        , dateLimit = dateLimit
        , dateRangeOffset = dateRangeOffset_
        , timePickers = timePickers
        }


{-| The DateRangePicker's update function.
-}
update : Msg -> Model -> ( Model, Cmd Msg, ExtMsg )
update msg (Model model) =
    case msg of
        PreviousMonth ->
            ( Model { model | primaryDate = DateTime.decrementMonth model.primaryDate }
            , Cmd.none
            , None
            )

        NextMonth ->
            ( Model { model | primaryDate = DateTime.incrementMonth model.primaryDate }
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
            ( Model (Internal.updateDateRangeOffset model_)
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
            ( Model updatedModel
            , Cmd.none
            , None
            )

        ResetVisualSelection ->
            case model.range of
                BothSelected (Visually start _) ->
                    ( Model { model | range = StartDateSelected start }
                    , Cmd.none
                    , None
                    )

                _ ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        ShowClockView ->
            -- This message is only used on the DoubleCalendar view case.
            -- If the viewType is of SingleCalendar type then there is no
            -- switchViewButton that triggers this message.
            ( Model { model | viewType = Internal.DoubleTimePicker }
            , Cmd.none
            , None
            )

        ShowCalendarView ->
            -- This message is only used on the DoubleClock view case.
            -- If the viewType is of SingleCalendar type then there is no
            -- switchViewButton that triggers this message.
            ( Model { model | viewType = Internal.DoubleCalendar }
            , Cmd.none
            , None
            )

        InitialiseTimePickers ->
            case model.timePickers of
                NotInitialised { pickerType, defaultTime, pickerTitles, mirrorTimes } ->
                    case model.range of
                        BothSelected (Chosen start end) ->
                            let
                                timePicker =
                                    TimePicker.initialise { time = defaultTime, pickerType = pickerType }
                            in
                            ( Model
                                { model
                                    | timePickers =
                                        TimePickers
                                            { startPicker = timePicker
                                            , endPicker = timePicker
                                            , pickerTitles = pickerTitles
                                            , mirrorTimes = mirrorTimes
                                            }
                                }
                            , Cmd.none
                            , None
                            )

                        _ ->
                            ( Model model
                            , Cmd.none
                            , None
                            )

                _ ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        ToggleTimeMirroring ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, pickerTitles, mirrorTimes }, BothSelected (Chosen start end) ) ->
                    ( Model
                        { model
                            | timePickers =
                                TimePickers { startPicker = startPicker, endPicker = endPicker, pickerTitles = pickerTitles, mirrorTimes = not mirrorTimes }
                        }
                    , fireAction (SyncTimePickers start)
                    , None
                    )

                _ ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        SyncTimePickers dateTime ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, pickerTitles, mirrorTimes }, BothSelected (Chosen start end) ) ->
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
                        ( Model
                            { model
                                | range = BothSelected (Chosen updatedStartDate updatedEndDate)
                                , timePickers =
                                    TimePickers
                                        { startPicker = timePickerUpdateFn startPicker
                                        , endPicker = timePickerUpdateFn endPicker
                                        , pickerTitles = pickerTitles
                                        , mirrorTimes = mirrorTimes
                                        }
                            }
                        , Cmd.none
                        , DateRangeSelected (Just { startDate = updatedStartDate, endDate = updatedEndDate })
                        )

                    else
                        ( Model model
                        , Cmd.none
                        , None
                        )

                _ ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        RangeStartPickerMsg subMsg ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, pickerTitles, mirrorTimes }, BothSelected (Chosen start end) ) ->
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
                            TimePickers { startPicker = subModel, endPicker = endPicker, pickerTitles = pickerTitles, mirrorTimes = mirrorTimes }
                    in
                    ( Model
                        { model
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
                    ( Model model
                    , Cmd.none
                    , None
                    )

        RangeEndPickerMsg subMsg ->
            case ( model.timePickers, model.range ) of
                ( TimePickers { startPicker, endPicker, pickerTitles, mirrorTimes }, BothSelected (Chosen start end) ) ->
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
                            TimePickers { startPicker = startPicker, endPicker = subModel, pickerTitles = pickerTitles, mirrorTimes = mirrorTimes }
                    in
                    ( Model
                        { model
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
                    ( Model model
                    , Cmd.none
                    , None
                    )

        MoveToToday ->
            ( Model { model | primaryDate = DateTime.setDate (DateTime.getDate model.today) model.primaryDate }
            , Cmd.none
            , None
            )

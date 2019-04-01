module DateRangePicker exposing
    ( Model, Msg, ExtMsg(..), SelectedDateRange
    , initialise, update, view
    )

{-| The `DateRangePicker` component is a DatePicker that allows the user to
select a **range of dates**. It has its own [Model](DateRangePicker#Model)
and [Msg](DateRangePicker#Msg) types which handle the rendering and date
selection functionalities. It also exposes a list of **external messages**
( [ExtMsg](DateRangePicker#ExtMsg) ) which can be used by the consumer to extract the selected dates in
the form of a **startDate** and an **endDate**. You can see a simple `DateRangePicker`
application in [this ellie-app example](https://ellie-app.com/new) or you can clone [this
example repository](https://github.com/PanagiotisGeorgiadis/).

@docs Model, Msg, ExtMsg, SelectedDateRange

@docs initialise, update, view

-}

import Clock
import DateRangePicker.Internal.Update as Internal
    exposing
        ( DateRange(..)
        , DateRangeOffset(..)
        , Model(..)
        , Msg(..)
        , SelectionType(..)
        , TimePickerState(..)
        )
import DateRangePicker.Internal.View as Internal
import DateRangePicker.Types
    exposing
        ( CalendarConfig
        , DateLimit(..)
        , TimePickerConfig
        , ViewType(..)
        )
import DateTime exposing (DateTime)
import Html exposing (Html)
import TimePicker.Update as TimePicker
import Utils.Actions exposing (fireAction)
import Utils.DateTime as DateTime


{-| The `DateRangePicker` model.
-}
type alias Model =
    Internal.Model


{-| The internal messages that are being used by the `DateRangePicker`. You can map
this message with your own message in order to "wire up" the `DateRangePicker` with your
application. Example of wiring up:

    import DateRangePicker

    type Msg
        = DateRangePickerMsg DateRangePicker.Msg

    DateRangePickerMsg subMsg ->
        let
            ( subModel, subCmd, extMsg ) =
                DateRangePicker.update subMsg model.dateRangePicker

            selectedDateRange =
                case extMsg of
                    DateRangePicker.DateRangeSelected dateRange ->
                        dateRange

                    DateRangePicker.None ->
                        Nothing
        in
        ( { model | dateRangePicker = subModel }
        , Cmd.map DateRangePickerMsg subCmd
        )

-}
type alias Msg =
    Internal.Msg


{-| The _**external messages**_ that are being used to pass information to the
parent component. These messages are being returned by the [update function](DateRangePicker#update)
so that the consumer can pattern match on them and get the selected `DateTime`.
-}
type ExtMsg
    = None
    | DateRangeSelected (Maybe SelectedDateRange)


{-| The start and end dates returned as a payload by the `DateRangeSelected` external message.
-}
type alias SelectedDateRange =
    { startDate : DateTime
    , endDate : DateTime
    }


{-| Validates the primaryDate based on the dateLimit.
-}
validatePrimaryDate : CalendarConfig -> DateTime
validatePrimaryDate { today, primaryDate, dateLimit } =
    let
        date =
            -- Check if the user has specified a primaryDate.
            -- Otherwise use today's date as our primaryDate
            -- with the time set to midnight.
            case primaryDate of
                Just d ->
                    d

                Nothing ->
                    DateTime.setTime Clock.midnight today
    in
    case dateLimit of
        DateLimit { minDate, maxDate } ->
            let
                isBetweenConstrains =
                    (DateTime.compareYearMonth minDate date == LT || DateTime.compareYearMonth minDate date == EQ)
                        && (DateTime.compareYearMonth maxDate date == GT || DateTime.compareYearMonth maxDate date == EQ)
            in
            -- If there is a DateLimit and the date is between the constrains then proceed.
            -- If the date is outside of the constrains then set the primaryDate == minDate.
            if isBetweenConstrains then
                date

            else
                minDate

        NoLimit { disablePastDates } ->
            -- If we've disabled past dates and the `primaryDate` is a past date,
            -- set the primaryDate == today. Else proceed.
            if disablePastDates && DateTime.compareYearMonth date today == LT then
                today

            else
                date


{-| The initialisation function of the `DateRangePicker`.

    import Clock
    import DateRangePicker
    import DateTime
    import Time exposing (Month(..))
    import TimePicker.Types as TimePicker

    myInitialise : DateTime -> DateRangePicker.Model
    myInitialise today =
        let
            ( date1, date2 ) =
                ( DateTime.fromRawParts { day = 1, month = Jan, year = 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                , DateTime.fromRawParts { day = 31, month = Dec, year = 2019 } { hours = 0, minutes = 0, seconds = 0, milliseconds = 0 }
                )

            calendarConfig =
                { today = today
                , primaryDate = Nothing
                , dateLimit =
                    case ( date1, date2 ) of
                        ( Just d1, Just d2 ) ->
                            DateLimit { minDate = d1, maxDate = d2 }

                        _ ->
                            NoLimit { disablePastDates = False }
                , dateRangeOffset = Just { minDateRangeLength = 7 }
                }

            timePickerConfig =
                Just
                    { pickerType = TimePicker.HH_MM { hoursStep = 1, minutesStep = 5 }
                    , defaultTime = Clock.midnight
                    , pickerTitles = { start = "Start Date Time", end = "End Date Time" }
                    , mirrorTimes = True
                    }
        in
        DateRangePicker.initialise DateRangePicker.Single calendarConfig timePickerConfig

-}
initialise : ViewType -> CalendarConfig -> Maybe TimePickerConfig -> Model
initialise viewType ({ today, dateLimit, dateRangeOffset } as calendarConfig) timePickerConfig =
    let
        viewType_ =
            case viewType of
                Single ->
                    Internal.SingleCalendar

                Double ->
                    Internal.DoubleCalendar

        ( primaryDate_, timePickers ) =
            let
                dateTime =
                    validatePrimaryDate calendarConfig
            in
            case timePickerConfig of
                Just config ->
                    ( DateTime.setTime config.defaultTime dateTime
                    , NotInitialised config
                    )

                Nothing ->
                    ( dateTime
                    , NoTimePickers
                    )

        dateRangeOffset_ =
            case dateRangeOffset of
                Just { minDateRangeLength } ->
                    Offset { minDateRangeLength = minDateRangeLength, invalidDates = [] }

                Nothing ->
                    NoOffset
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


{-| The `DateRangePicker's` update function. Can be used in order to "wire up" the `DateRangePicker`
with the **main application** as shown in the example of the [DateRangePicker.Msg](DateRangePicker#Msg).
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


{-| The `DateRangePicker` view function.
-}
view : Model -> Html Msg
view =
    Internal.view

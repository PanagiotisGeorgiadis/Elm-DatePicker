module DateRangePicker exposing
    ( Model, Msg, ExtMsg(..), SelectedDateRange
    , resetVisualSelection, setDateRange
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

@docs resetVisualSelection, setDateRange

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

        NoLimit ->
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
                            NoLimit
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
                Just { pickerType, defaultTime, pickerTitles, mirrorTimes } ->
                    let
                        timePicker =
                            TimePicker.initialise { time = defaultTime, pickerType = pickerType }
                    in
                    ( DateTime.setTime defaultTime dateTime
                    , TimePickers
                        { startPicker = timePicker
                        , endPicker = timePicker
                        , pickerTitles = pickerTitles
                        , mirrorTimes = mirrorTimes
                        }
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
                            let
                                ( start_, end_ ) =
                                    case model.timePickers of
                                        TimePickers { startPicker, endPicker } ->
                                            ( DateTime.setTime (TimePicker.getTime startPicker) start
                                            , DateTime.setTime (TimePicker.getTime endPicker) date
                                            )

                                        NoTimePickers ->
                                            ( start
                                            , date
                                            )
                            in
                            ( { model | range = BothSelected (Chosen start_ end_) }
                            , Internal.showClockView model
                            , DateRangeSelected (Just { startDate = start_, endDate = end_ })
                            )

                        GT ->
                            let
                                ( start_, end_ ) =
                                    case model.timePickers of
                                        TimePickers { startPicker, endPicker } ->
                                            ( DateTime.setTime (TimePicker.getTime startPicker) date
                                            , DateTime.setTime (TimePicker.getTime endPicker) start
                                            )

                                        NoTimePickers ->
                                            ( date
                                            , start
                                            )
                            in
                            ( { model | range = BothSelected (Chosen start_ end_) }
                            , Internal.showClockView model
                            , DateRangeSelected (Just { startDate = start_, endDate = end_ })
                            )

                ( model_, cmd, extMsg ) =
                    -- Bare in mind that this model.range is essentialy the
                    -- 'previous' state.
                    case model.range of
                        StartDateSelected start ->
                            updateModel start

                        BothSelected (Visually start end) ->
                            updateModel start

                        BothSelected (Chosen start end) ->
                            ( { model | range = StartDateSelected date }
                            , Cmd.none
                            , None
                            )

                        NoneSelected ->
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

        ToggleTimeMirroring ->
            case model.timePickers of
                TimePickers ({ startPicker, mirrorTimes } as pickers) ->
                    ( Model
                        { model
                            | timePickers =
                                TimePickers { pickers | mirrorTimes = not mirrorTimes }
                        }
                    , fireAction (SyncTimePickers (TimePicker.getTime startPicker))
                    , None
                    )

                NoTimePickers ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        SyncTimePickers time ->
            case model.timePickers of
                TimePickers ({ startPicker, endPicker, mirrorTimes } as pickers) ->
                    if mirrorTimes then
                        let
                            updateFn =
                                TimePicker.updateDisplayTime time

                            ( range, extMsg ) =
                                case model.range of
                                    BothSelected (Chosen start end) ->
                                        let
                                            ( updatedStartDate, updatedEndDate ) =
                                                ( DateTime.setTime time start
                                                , DateTime.setTime time end
                                                )
                                        in
                                        ( BothSelected (Chosen updatedStartDate updatedEndDate)
                                        , DateRangeSelected (Just { startDate = updatedStartDate, endDate = updatedEndDate })
                                        )

                                    _ ->
                                        ( model.range
                                        , None
                                        )
                        in
                        ( Model
                            { model
                                | range = range
                                , timePickers =
                                    TimePickers
                                        { pickers
                                            | startPicker = updateFn startPicker
                                            , endPicker = updateFn endPicker
                                        }
                            }
                        , Cmd.none
                        , extMsg
                        )

                    else
                        ( Model model
                        , Cmd.none
                        , None
                        )

                NoTimePickers ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        RangeStartPickerMsg subMsg ->
            case model.timePickers of
                TimePickers ({ startPicker } as pickers) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg startPicker

                        ( range, cmd, externalMsg ) =
                            case ( extMsg, model.range ) of
                                ( TimePicker.UpdatedTime time, BothSelected (Chosen start end) ) ->
                                    let
                                        updatedStart =
                                            DateTime.setTime time start
                                    in
                                    ( BothSelected (Chosen updatedStart end)
                                    , fireAction (SyncTimePickers time)
                                    , DateRangeSelected (Just { startDate = updatedStart, endDate = end })
                                    )

                                ( TimePicker.UpdatedTime time, _ ) ->
                                    ( model.range
                                    , fireAction (SyncTimePickers time)
                                    , None
                                    )

                                _ ->
                                    ( model.range
                                    , Cmd.none
                                    , None
                                    )
                    in
                    ( Model
                        { model
                            | range = range
                            , timePickers = TimePickers { pickers | startPicker = subModel }
                        }
                    , Cmd.batch
                        [ Cmd.map RangeStartPickerMsg subCmd
                        , cmd
                        ]
                    , externalMsg
                    )

                NoTimePickers ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        RangeEndPickerMsg subMsg ->
            case model.timePickers of
                TimePickers ({ endPicker } as pickers) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg endPicker

                        ( range, cmd, externalMsg ) =
                            case ( extMsg, model.range ) of
                                ( TimePicker.UpdatedTime time, BothSelected (Chosen start end) ) ->
                                    let
                                        updatedEnd =
                                            DateTime.setTime time end
                                    in
                                    ( BothSelected (Chosen start updatedEnd)
                                    , fireAction (SyncTimePickers time)
                                    , DateRangeSelected (Just { startDate = start, endDate = updatedEnd })
                                    )

                                ( TimePicker.UpdatedTime time, _ ) ->
                                    ( model.range
                                    , fireAction (SyncTimePickers time)
                                    , None
                                    )

                                _ ->
                                    ( model.range
                                    , Cmd.none
                                    , None
                                    )
                    in
                    ( Model
                        { model
                            | range = range
                            , timePickers = TimePickers { pickers | endPicker = subModel }
                        }
                    , Cmd.batch
                        [ Cmd.map RangeEndPickerMsg subCmd
                        , cmd
                        ]
                    , externalMsg
                    )

                NoTimePickers ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

        MoveToToday ->
            ( Model { model | primaryDate = DateTime.setDate (DateTime.getDate model.today) model.primaryDate }
            , Cmd.none
            , None
            )


{-| Helper function that resets the `Visually` selected date range. **It will reset the date range if
the user has selected only a start date.** In case the user has already selected a _**valid date range**_
this function will do nothing.
-}
resetVisualSelection : Model -> Model
resetVisualSelection (Model model) =
    case model.range of
        BothSelected (Visually start _) ->
            Model (Internal.updateDateRangeOffset { model | range = NoneSelected })

        StartDateSelected start ->
            Model (Internal.updateDateRangeOffset { model | range = NoneSelected })

        _ ->
            Model model


{-| Sets the date range based on the dates that were provided.
This can be useful in setting a **default value** or even **updating the date range** from
an "external" action that took place in the "parent" component.

**Note:**

  - If you've provided a `DateLimit` on your `DateRangePicker` module you need to make
    sure that the **start and end dates** that you are using here **are within these limitations.**

  - If you are using a **dateRangeOffset** limitation on your `DateRangePicker`, then you'll
    need to make sure that the **start and end dates** are at least **n** number of dates apart,
    where _**n == minDateRangeLength**_.

  - In the case of an **invalid start or end date** the `setDateRange` function
    will return the `Model` without any changes.

-}
setDateRange : SelectedDateRange -> Model -> Model
setDateRange { startDate, endDate } (Model model) =
    let
        isOutOfBounds date =
            case model.dateLimit of
                DateLimit { minDate, maxDate } ->
                    DateTime.compareDates date minDate == LT || DateTime.compareDates date maxDate == GT

                NoLimit ->
                    False

        isLessThanOffset =
            case model.dateRangeOffset of
                Offset { minDateRangeLength } ->
                    let
                        dateRange =
                            DateTime.getDateRange startDate endDate Clock.midnight
                    in
                    List.length dateRange < minDateRangeLength

                NoOffset ->
                    False
    in
    if isOutOfBounds startDate || isOutOfBounds endDate || isLessThanOffset then
        Model model

    else
        case DateTime.compareDates startDate endDate of
            EQ ->
                Model model

            LT ->
                Model (Internal.updateDateRangeOffset { model | range = BothSelected (Chosen startDate endDate) })

            GT ->
                Model (Internal.updateDateRangeOffset { model | range = BothSelected (Chosen endDate startDate) })


{-| The `DateRangePicker` view function.
-}
view : Model -> Html Msg
view =
    Internal.view

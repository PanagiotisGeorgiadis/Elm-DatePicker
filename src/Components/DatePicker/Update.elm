module Components.DatePicker.Update exposing
    ( DateLimit(..)
    , Model
    , Msg(..)
    , TimePickerState(..)
    , ViewType(..)
    , initialise
    , update
    )

import Clock
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)
import Utils.Actions exposing (fireAction)


{-| Expose
-}
type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , selectedDate : Maybe DateTime
    , timePicker : TimePickerState
    }


{-| Expose
-}
type alias Config =
    { today : DateTime
    , primaryDate : DateTime
    , dateLimit : DateLimit
    }


{-| Expose
-}
type alias TimePickerConfig =
    { pickerType : TimePicker.PickerType
    , defaultTime : Clock.Time
    }


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


{-| Internal
-}
type TimePickerState
    = NoTimePicker
    | NotInitialised { pickerType : TimePicker.PickerType, defaultTime : Clock.Time }
    | TimePicker TimePicker.Model


{-| Expose
-}
initialise : ViewType -> Config -> Maybe TimePickerConfig -> Model
initialise viewType { today, primaryDate, dateLimit } timePickerConfig =
    { today = today
    , viewType = viewType
    , primaryDate = primaryDate
    , selectedDate = Nothing
    , dateLimit = dateLimit
    , timePicker =
        case timePickerConfig of
            Just config ->
                NotInitialised config

            Nothing ->
                NoTimePicker
    }


{-| Expose
-}
type Msg
    = PreviousMonth
    | NextMonth
    | SelectDate DateTime
    | MoveToToday
    | InitialiseTimePicker
    | TimePickerMsg TimePicker.Msg


{-| Expose
-}
type ExtMsg
    = None
    | SelectedDate DateTime



-- | SelectedDateAndTime


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
                -- Getting the time if it has already been selected
                -- by the user in order to update it on the newly
                -- selected date. For example: The user has selected
                -- 16 Sep 2019 21:00 but now they want to choose 17 Sep 2019.
                -- We maintain the time as 21:00 since they've already made
                -- this choice.
                ( time, cmd ) =
                    case model.timePicker of
                        TimePicker timePicker ->
                            ( TimePicker.getTime timePicker
                            , Cmd.none
                            )

                        _ ->
                            ( DateTime.getTime date
                            , fireAction InitialiseTimePicker
                            )

                updatedDate =
                    DateTime.setTime time date
            in
            case model.selectedDate of
                Just selected ->
                    if DateTime.getDate updatedDate == DateTime.getDate selected then
                        ( { model | selectedDate = Nothing }
                        , Cmd.none
                        , SelectedDate date
                        )

                    else
                        ( { model | selectedDate = Just updatedDate }
                        , cmd
                        , SelectedDate date
                        )

                Nothing ->
                    ( { model | selectedDate = Just updatedDate }
                    , cmd
                    , SelectedDate date
                    )

        MoveToToday ->
            ( { model | primaryDate = DateTime.setDate (DateTime.getDate model.today) model.primaryDate }
            , Cmd.none
            , None
            )

        InitialiseTimePicker ->
            case ( model.selectedDate, model.timePicker ) of
                ( Just dateTime, NotInitialised { pickerType, defaultTime } ) ->
                    let
                        timePicker =
                            TimePicker
                                (TimePicker.initialise
                                    { time = defaultTime
                                    , pickerType = pickerType
                                    }
                                )
                    in
                    ( { model | timePicker = timePicker }
                    , Cmd.none
                    , None
                    )

                _ ->
                    ( model
                    , Cmd.none
                    , None
                    )

        TimePickerMsg subMsg ->
            case ( model.selectedDate, model.timePicker ) of
                ( Just date, TimePicker timePicker ) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg timePicker

                        updatedDate =
                            case extMsg of
                                TimePicker.UpdatedTime newTime ->
                                    Just (DateTime.setTime newTime date)

                                _ ->
                                    model.selectedDate
                    in
                    ( { model
                        | selectedDate = updatedDate
                        , timePicker = TimePicker subModel
                      }
                    , Cmd.map TimePickerMsg subCmd
                    , None
                    )

                _ ->
                    ( model
                    , Cmd.none
                    , None
                    )

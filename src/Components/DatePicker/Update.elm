module Components.DatePicker.Update exposing
    ( DateLimit(..)
    , Model
    , Msg(..)
    , TimePickerConfig(..)
    , TimePickerState(..)
    , ViewType(..)
    , initialise
    , update
    )

import Clock
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)
import Utils.Actions exposing (fireAction)


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , selectedDate : Maybe DateTime
    , timePicker : TimePickerState
    }


type alias Config =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , timePickerConfig : TimePickerConfig
    }


type TimePickerConfig
    = NoPicker
    | TimePickerConfig { pickerType : TimePicker.PickerType, defaultTime : Clock.Time }


{-| Extract to another file as a common type
-}
type ViewType
    = Single
    | Double


type DateLimit
    = DateLimit { minDate : DateTime, maxDate : DateTime }
    | NoLimit { disablePastDates : Bool }


type TimePickerState
    = NoTimePicker
    | NotInitialised { pickerType : TimePicker.PickerType, defaultTime : Clock.Time }
    | TimePicker TimePicker.Model


initialise : Config -> Model
initialise { today, viewType, primaryDate, dateLimit, timePickerConfig } =
    { today = today
    , viewType = viewType
    , primaryDate = primaryDate
    , selectedDate = Nothing
    , dateLimit = dateLimit
    , timePicker =
        case timePickerConfig of
            NoPicker ->
                NoTimePicker

            TimePickerConfig config ->
                NotInitialised config
    }


type Msg
    = NoOp
    | PreviousMonth
    | NextMonth
    | SelectDate DateTime
    | MoveToToday
    | InitialiseTimePicker
    | TimePickerMsg TimePicker.Msg


type ExtMsg
    = None
    | SelectedDate DateTime



-- | SelectedDateAndTime


update : Msg -> Model -> ( Model, Cmd Msg, ExtMsg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            , None
            )

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
            case model.selectedDate of
                Just dateTime ->
                    let
                        timePicker =
                            case model.timePicker of
                                NotInitialised { pickerType, defaultTime } ->
                                    TimePicker
                                        (TimePicker.initialise
                                            { time = defaultTime
                                            , pickerType = pickerType
                                            }
                                        )

                                _ ->
                                    model.timePicker
                    in
                    ( { model | timePicker = timePicker }
                    , Cmd.none
                    , None
                    )

                Nothing ->
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

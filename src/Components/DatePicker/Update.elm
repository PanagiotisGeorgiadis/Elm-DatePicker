module Components.DatePicker.Update exposing
    ( DateLimit(..)
    , Model
    , Msg(..)
    , ViewType(..)
    , initialise
    , update
    )

import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)
import Task


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , selectedDate : Maybe DateTime
    , timePicker : Maybe TimePicker.Model
    , pickerType : TimePicker.PickerType
    }


type alias Config =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , pickerType : TimePicker.PickerType
    }


{-| Extract to another file as a common type
-}
type ViewType
    = Single
    | Double


type DateLimit
    = DateLimit { minDate : DateTime, maxDate : DateTime }
    | NoLimit { disablePastDates : Bool }


initialise : Config -> Model
initialise { today, viewType, primaryDate, dateLimit, pickerType } =
    { today = today
    , viewType = viewType
    , primaryDate = primaryDate
    , selectedDate = Nothing
    , dateLimit = dateLimit
    , timePicker = Nothing
    , pickerType = pickerType
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
                        Just picker ->
                            ( picker.time
                            , Cmd.none
                            )

                        Nothing ->
                            ( DateTime.getTime date
                            , Task.perform (\_ -> InitialiseTimePicker) (Task.succeed ())
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
                            TimePicker.initialise
                                { time = DateTime.getTime dateTime
                                , pickerType = model.pickerType

                                -- TimePicker.HH_MM_SS_MMMM { hoursStep = 1, minutesStep = 5, secondsStep = 10, millisecondsStep = 100 }
                                -- TimePicker.HH_MM_SS { hoursStep = 1, minutesStep = 5, secondsStep = 10 }
                                -- TimePicker.HH_MM { hoursStep = 1, minutesStep = 5 }
                                -- TimePicker.HH { hoursStep = 1 }
                                }
                    in
                    ( { model | timePicker = Just timePicker }
                    , Cmd.none
                    , None
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    , None
                    )

        TimePickerMsg subMsg ->
            case model.timePicker of
                Just timePicker ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg timePicker

                        updatedDate =
                            case ( model.selectedDate, extMsg ) of
                                ( Just date, TimePicker.UpdatedTime newTime ) ->
                                    Just (DateTime.setTime newTime date)

                                _ ->
                                    model.selectedDate
                    in
                    ( { model
                        | selectedDate = updatedDate
                        , timePicker = Just subModel
                      }
                    , Cmd.map TimePickerMsg subCmd
                    , None
                    )

                Nothing ->
                    ( model
                    , Cmd.none
                    , None
                    )

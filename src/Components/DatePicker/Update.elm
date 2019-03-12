module Components.DatePicker.Update exposing
    ( ExtMsg(..)
    , Model
    , Msg
    , initialise
    , update
    )

import Clock
import Components.DatePicker.Internal.Update as Internal
    exposing
        ( Model(..)
        , Msg(..)
        , TimePickerState(..)
        )
import Components.DatePicker.Types
    exposing
        ( CalendarConfig
        , DateLimit(..)
        , TimePickerConfig
        , ViewType(..)
        )
import Components.TimePicker.Update as TimePicker
import DateTime exposing (DateTime)
import Utils.Actions exposing (fireAction)


{-| An Alias of the DatePicker Model.
-}
type alias Model =
    Internal.Model


{-| The function used to initialise the `DateRangePicker Model`.
-}
initialise : ViewType -> CalendarConfig -> Maybe TimePickerConfig -> Model
initialise viewType { today, primaryDate, dateLimit } timePickerConfig =
    let
        primaryDate_ =
            case timePickerConfig of
                Just { defaultTime } ->
                    DateTime.setTime defaultTime primaryDate

                Nothing ->
                    primaryDate
    in
    Model
        { today = today
        , viewType = viewType
        , primaryDate = primaryDate_
        , selectedDate = Nothing
        , dateLimit = dateLimit
        , timePicker =
            case timePickerConfig of
                Just config ->
                    NotInitialised config

                Nothing ->
                    NoTimePicker
        }


{-| An alias of the DatePicker internal messages.
-}
type alias Msg =
    Internal.Msg


{-| The External messages that are being used to transform information to the
parent component.
-}
type ExtMsg
    = None
    | DateSelected (Maybe DateTime)


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
                -- Getting the time if it has already been selected
                -- by the user in order to update it on the newly
                -- selected date. For example: The user has selected
                -- 16 Sep 2019 21:00 but now they want to choose 17 Sep 2019.
                -- We maintain the time as 21:00 since they've already made
                -- this choice.
                ( time, cmd ) =
                    case model.timePicker of
                        TimePicker { timePicker } ->
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
                        ( Model { model | selectedDate = Nothing }
                        , Cmd.none
                        , DateSelected Nothing
                        )

                    else
                        ( Model { model | selectedDate = Just updatedDate }
                        , cmd
                        , DateSelected (Just updatedDate)
                        )

                Nothing ->
                    ( Model { model | selectedDate = Just updatedDate }
                    , cmd
                    , DateSelected (Just updatedDate)
                    )

        MoveToToday ->
            ( Model { model | primaryDate = DateTime.setDate (DateTime.getDate model.today) model.primaryDate }
            , Cmd.none
            , None
            )

        InitialiseTimePicker ->
            let
                updatedModel =
                    case ( model.selectedDate, model.timePicker ) of
                        ( Just dateTime, NotInitialised { pickerType, defaultTime, pickerTitle } ) ->
                            let
                                timePicker =
                                    TimePicker
                                        { timePicker = TimePicker.initialise { time = defaultTime, pickerType = pickerType }
                                        , pickerTitle = pickerTitle
                                        }
                            in
                            { model | timePicker = timePicker }

                        _ ->
                            model
            in
            ( Model updatedModel
            , Cmd.none
            , None
            )

        TimePickerMsg subMsg ->
            case ( model.selectedDate, model.timePicker ) of
                ( Just date, TimePicker { timePicker, pickerTitle } ) ->
                    let
                        ( subModel, subCmd, extMsg ) =
                            TimePicker.update subMsg timePicker

                        updatedDate =
                            case extMsg of
                                TimePicker.UpdatedTime newTime ->
                                    Just (DateTime.setTime newTime date)

                                _ ->
                                    Just date
                    in
                    ( Model
                        { model
                            | selectedDate = updatedDate
                            , timePicker = TimePicker { timePicker = subModel, pickerTitle = pickerTitle }
                        }
                    , Cmd.map TimePickerMsg subCmd
                    , DateSelected updatedDate
                    )

                _ ->
                    ( Model model
                    , Cmd.none
                    , None
                    )

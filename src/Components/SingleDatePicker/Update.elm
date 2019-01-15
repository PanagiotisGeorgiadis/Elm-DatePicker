module Components.SingleDatePicker.Update exposing (ExternalMsg(..), Model, Msg(..), initialise, update)

-- import DateTime.Calendar as Calendar

import DateTime.DateTime as DateTime exposing (DateTime)


type alias Model =
    { today : DateTime
    , primaryDate : DateTime
    , selectedDate : Maybe DateTime
    , disablePastDates : Bool
    }


initialise : DateTime -> Model
initialise today =
    { today = today
    , primaryDate = today
    , selectedDate = Nothing
    , disablePastDates = False
    }


type Msg
    = NoOp
    | PreviousMonth
    | NextMonth
    | SelectDate DateTime


type ExternalMsg
    = None
    | DateSelected DateTime


update : Model -> Msg -> ( Model, Cmd Msg, ExternalMsg )
update model msg =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            , None
            )

        PreviousMonth ->
            ( { model | primaryDate = DateTime.getPreviousMonth model.primaryDate }
            , Cmd.none
            , None
            )

        NextMonth ->
            ( { model | primaryDate = DateTime.getNextMonth model.primaryDate }
            , Cmd.none
            , None
            )

        SelectDate date ->
            ( { model | selectedDate = Just date }
            , Cmd.none
            , DateSelected date
            )

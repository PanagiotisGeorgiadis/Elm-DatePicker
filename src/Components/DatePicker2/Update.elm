module Components.DatePicker2.Update exposing (DatePickerConfig, Model, Msg(..), ViewType(..), initialise, update)

import DateTime.DateTime as DateTime exposing (DateTime)
import Models.Calendar exposing (DateLimit)


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , disablePastDates : Bool
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
    , selectedDate : Maybe DateTime
    , dateSelectionHandler : Maybe (DateTime -> Msg)
    }


type alias DatePickerConfig =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , disablePastDates : Bool
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
    }



{- Extract to another file as a common type -}


type ViewType
    = Single
    | Double


initialise : DatePickerConfig -> Model
initialise { today, viewType, primaryDate, pastDatesLimit, futureDatesLimit, disablePastDates } =
    { today = today
    , viewType = viewType
    , primaryDate = primaryDate
    , selectedDate = Nothing
    , pastDatesLimit = pastDatesLimit
    , futureDatesLimit = futureDatesLimit
    , disablePastDates = disablePastDates
    , dateSelectionHandler = Just SelectDate
    }


type Msg
    = NoOp
    | PreviousMonth
    | NextMonth
      -- | DateHoverDetected DateTime
      -- | ResetShadowDateRange
    | SelectDate DateTime


type ExternalMsg
    = None


update : Msg -> Model -> ( Model, Cmd Msg, ExternalMsg )
update msg model =
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
            if model.selectedDate == Just date then
                ( { model | selectedDate = Nothing }
                , Cmd.none
                , None
                )

            else
                ( { model | selectedDate = Just date }
                , Cmd.none
                , None
                )

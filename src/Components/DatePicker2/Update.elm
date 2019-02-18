module Components.DatePicker2.Update exposing
    ( DatePickerConfig
    , Model
    , Msg(..)
    , ViewType(..)
    , initialise
    , update
    )

import DateTime exposing (DateTime)
import Models.Calendar exposing (DateLimit)


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , disablePastDates : Bool
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
    , selectedDate : Maybe DateTime
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
    }


type Msg
    = NoOp
    | PreviousMonth
    | NextMonth
      -- | DateHoverDetected DateTime
      -- | ResetShadowDateRange
    | SelectDate DateTime


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        PreviousMonth ->
            ( { model | primaryDate = DateTime.decrementMonth model.primaryDate }
            , Cmd.none
            )

        NextMonth ->
            ( { model | primaryDate = DateTime.incrementMonth model.primaryDate }
            , Cmd.none
            )

        SelectDate date ->
            if model.selectedDate == Just date then
                ( { model | selectedDate = Nothing }
                , Cmd.none
                )

            else
                ( { model | selectedDate = Just date }
                , Cmd.none
                )

module Components.DatePicker2.Update exposing
    ( DateLimit(..)
    , DatePickerConfig
    , Model
    , Msg(..)
    , ViewType(..)
    , initialise
    , update
    )

import DateTime exposing (DateTime)


type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit
    , selectedDate : Maybe DateTime
    }


type alias DatePickerConfig =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , dateLimit : DateLimit
    }


{-| Extract to another file as a common type
-}
type ViewType
    = Single
    | Double


type DateLimit
    = DateLimit DateLimitation
    | NoLimit NoLimitConfig


type alias DateLimitation =
    { minDate : DateTime
    , maxDate : DateTime
    }


type alias NoLimitConfig =
    { disablePastDates : Bool
    }


initialise : DatePickerConfig -> Model
initialise { today, viewType, primaryDate, dateLimit } =
    { today = today
    , viewType = viewType
    , primaryDate = primaryDate
    , selectedDate = Nothing
    , dateLimit = dateLimit
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

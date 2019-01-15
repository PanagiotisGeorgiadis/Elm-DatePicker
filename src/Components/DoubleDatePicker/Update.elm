module Components.DoubleDatePicker.Update exposing (ExternalMsg(..), Model, Msg(..), initialise, update)

-- import DateTime.Calendar as Calendar

import DateTime.DateTime as DateTime exposing (DateTime)


type alias Model =
    { today : DateTime
    , primaryDate : DateTime

    -- , dateSelectionHandler : Maybe (Calendar.Date -> msg)
    -- , singleDate : Maybe Calendar.Date
    , rangeStart : Maybe DateTime
    , rangeEnd : Maybe DateTime

    -- , shadowRangeStart : Maybe Calendar.Date
    , shadowRangeEnd : Maybe DateTime
    , dateRange : List DateTime
    , disablePastDates : Bool
    }


type Msg
    = NoOp
    | PreviousMonth
    | NextMonth
    | SelectDate DateTime
    | DateHoverDetected DateTime
    | ResetShadowDateRange


type ExternalMsg
    = None


initialise : DateTime -> Model
initialise today =
    { today = today
    , primaryDate = today

    -- , dateSelectionHandler : Maybe (Calendar.Date -> msg)
    -- , singleDate : Maybe Calendar.Date
    , rangeStart = Nothing
    , rangeEnd = Nothing

    -- , shadowRangeStart = Nothing
    , shadowRangeEnd = Nothing
    , dateRange = []
    , disablePastDates = False
    }


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
            let
                -- _ = Debug.log "SelectDate date" date
                -- _ = Debug.log "model" model
                updatedModel =
                    { model | shadowRangeEnd = Nothing }

                _ =
                    Debug.log "SelectDate" updatedModel
            in
            case ( model.rangeStart, model.rangeEnd ) of
                ( Just start, Nothing ) ->
                    -- Date Range Complete
                    ( { updatedModel | rangeEnd = Just date }
                    , Cmd.none
                    , None
                    )

                ( Nothing, Just end ) ->
                    -- Some imposible state
                    ( { updatedModel
                        | rangeStart = Just date
                        , rangeEnd = Nothing
                      }
                    , Cmd.none
                    , None
                    )

                ( Just start, Just end ) ->
                    -- Resetting the date range here
                    ( { updatedModel
                        | rangeStart = Just date
                        , rangeEnd = Nothing
                      }
                    , Cmd.none
                    , None
                    )

                ( Nothing, Nothing ) ->
                    -- Starting the date range process.
                    ( { updatedModel | rangeStart = Just date }
                    , Cmd.none
                    , None
                    )

        DateHoverDetected date ->
            -- let
            --     _ = Debug.log "Date hover detected" date
            -- in
            case ( model.rangeStart, model.rangeEnd ) of
                ( Just start, Nothing ) ->
                    ( { model | shadowRangeEnd = Just date }
                    , Cmd.none
                    , None
                    )

                _ ->
                    ( { model | shadowRangeEnd = Nothing }
                    , Cmd.none
                    , None
                    )

        ResetShadowDateRange ->
            ( { model | shadowRangeEnd = Nothing }
            , Cmd.none
            , None
            )

module Components.DoubleDatePicker.Update exposing (ExternalMsg(..), Model, Msg(..), initialise, update)

import DateTime.DateTime as DateTime exposing (DateTime)
import Models.Calendar exposing (DateLimit)


type alias Model =
    { today : DateTime
    , primaryDate : DateTime
    , rangeStart : Maybe DateTime
    , rangeEnd : Maybe DateTime
    , shadowRangeEnd : Maybe DateTime
    , dateRange : List DateTime
    , showOnHover : Bool
    , disablePastDates : Bool
    , minDateRangeOffset : Int
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
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


type alias Config c =
    { c
        | showOnHover : Bool
        , disablePastDates : Bool
        , minDateRangeOffset : Int
        , futureDatesLimit : DateLimit
        , pastDatesLimit : DateLimit
    }


initialise : Config c -> DateTime -> Model
initialise { showOnHover, disablePastDates, minDateRangeOffset, futureDatesLimit, pastDatesLimit } today =
    { today = today
    , primaryDate = today
    , rangeStart = Nothing
    , rangeEnd = Nothing
    , shadowRangeEnd = Nothing
    , dateRange = []
    , showOnHover = showOnHover
    , disablePastDates = disablePastDates
    , minDateRangeOffset = minDateRangeOffset
    , pastDatesLimit = pastDatesLimit
    , futureDatesLimit = futureDatesLimit
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
                updatedModel =
                    { model | shadowRangeEnd = Nothing }
            in
            case ( model.rangeStart, model.rangeEnd ) of
                ( Just start, Nothing ) ->
                    -- Date Range Complete
                    case DateTime.compareDates start date of
                        LT ->
                            -- Normal case.
                            ( { updatedModel | rangeEnd = Just date }
                            , Cmd.none
                            , None
                            )

                        EQ ->
                            -- Cancels out the selected date.
                            ( { updatedModel | rangeStart = Nothing, rangeEnd = Nothing }
                            , Cmd.none
                            , None
                            )

                        GT ->
                            -- Reversed case. ie. the user selected the rangeEnd first.
                            ( { updatedModel | rangeStart = Just date, rangeEnd = Just start }
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

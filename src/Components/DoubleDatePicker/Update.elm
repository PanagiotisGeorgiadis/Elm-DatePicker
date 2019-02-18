module Components.DoubleDatePicker.Update exposing (ExternalMsg(..), Model, Msg(..), initialise, update)

import DateTime exposing (DateTime)
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
initialise { showOnHover, disablePastDates, minDateRangeOffset, pastDatesLimit, futureDatesLimit } today =
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
                model_ =
                    { model | shadowRangeEnd = Nothing }

                updatedModel =
                    case ( model.rangeStart, model.rangeEnd ) of
                        ( Just start, Nothing ) ->
                            -- Date Range Complete
                            case DateTime.compareDates start date of
                                LT ->
                                    -- Normal case.
                                    { model_ | rangeEnd = Just date }

                                EQ ->
                                    -- Cancels out the selected date.
                                    { model_ | rangeStart = Nothing, rangeEnd = Nothing }

                                GT ->
                                    -- Reversed case. ie. the user selected the rangeEnd first.
                                    { model_ | rangeStart = Just date, rangeEnd = Just start }

                        ( Nothing, Just end ) ->
                            -- Some imposible state
                            { model_ | rangeStart = Just date, rangeEnd = Nothing }

                        ( Just start, Just end ) ->
                            -- Resetting the date range here
                            { model_ | rangeStart = Just date, rangeEnd = Nothing }

                        ( Nothing, Nothing ) ->
                            -- Starting the date range process.
                            { model_ | rangeStart = Just date }
            in
            ( updatedModel
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

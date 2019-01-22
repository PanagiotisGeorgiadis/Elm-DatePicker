module Components.DateRangePicker.Update exposing
    ( ExternalMsg(..)
    , Model
    , Msg(..)
    , ViewType(..)
    , initialise
    , update
    )

import DateTime.DateTime as DateTime exposing (DateTime)
import Models.Calendar exposing (DateLimit)



{- Extract to another file as a common type -}


type ViewType
    = Single
    | Double


{-| type Model =
---- ShadowRangeModel {}
---- SimplifiedModel {}

Maybe do something like that on the initialise function here:
-- initialise : Config c -> Model
-- initialise { showOnHover } =
---- if showOnHover then
------ ShadowRangeModel
-------- {....
-------- , rangeStart : Nothing
-------- , rangeEnd : Nothing
-------- , shadowRangeEnd : Nothing
-------- .....
-------- }

---- else
------ SimplifiedModel
-------- {....
-------- }

So that you don't carry with you useless properties such as rangeStart, rangeEnd and shadowRangeEnd ?
If they are useless.

-}
type alias Model =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , rangeStart : Maybe DateTime -- Do we need that ?
    , rangeEnd : Maybe DateTime -- Do we need that ?
    , shadowRangeEnd : Maybe DateTime
    , dateRange : List DateTime

    --
    , showOnHover : Bool
    , disablePastDates : Bool

    -- , minDateRangeOffset : Int -- TODO
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
    }


type alias DatePickerConfig =
    { today : DateTime
    , viewType : ViewType
    , primaryDate : DateTime
    , showOnHover : Bool
    , disablePastDates : Bool

    -- , minDateRangeOffset : Int
    , pastDatesLimit : DateLimit
    , futureDatesLimit : DateLimit
    }


initialise : DatePickerConfig -> Model
initialise { today, viewType, primaryDate, showOnHover, disablePastDates, pastDatesLimit, futureDatesLimit } =
    { today = today
    , viewType = viewType
    , primaryDate = primaryDate
    , rangeStart = Nothing
    , rangeEnd = Nothing
    , shadowRangeEnd = Nothing
    , dateRange = []

    --
    , showOnHover = showOnHover
    , disablePastDates = disablePastDates

    -- , minDateRangeOffset = minDateRangeOffset
    --
    , pastDatesLimit = pastDatesLimit
    , futureDatesLimit = futureDatesLimit

    -- , selectedDate = Nothing
    -- , dateSelectionHandler = Just SelectDate
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
